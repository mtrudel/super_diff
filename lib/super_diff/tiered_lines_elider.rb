module SuperDiff
  class TieredLinesElider
    extend AttrExtras.mixin
    include Helpers

    method_object :lines

    def call
      if all_lines_are_changed_or_unchanged?
        lines
      else
        elided_lines
      end
    end

    private

    def all_lines_are_changed_or_unchanged?
      sheets.size == 1 &&
        sheets.first.range == Range.new(0, lines.length - 1)
    end

    def elided_lines
      boxes_to_elide.
        reverse.
        reduce(lines) do |lines_with_elisions, box|
          selected_lines = lines_with_elisions[box.range]
          with_slice_of_array_replaced(
            lines_with_elisions,
            box.range,
            Elision.new(
              indentation_level: box.indentation_level,
              children: selected_lines.map(&:as_elided),
            ),
          )
        end
    end

    def boxes_to_elide
      sheets_to_consider_for_eliding.reduce([]) do |array, sheet|
        array + (find_boxes_to_elide_within(sheet) || [])
      end
    end

    def sheets_to_consider_for_eliding
      sheets.select do |sheet|
        sheet.type == :clean && sheet.range.size > maximum
      end
    end

    def sheets
      @_sheets ||= BuildSheets.call(
        dirty_sheets: padded_dirty_sheets,
        lines: lines,
      )
    end

    def padded_dirty_sheets
      @_padded_dirty_sheets ||= combine_congruent_sheets(
        dirty_sheets.
        map(&:padded).
        map { |sheet| sheet.capped_to(0, lines.size - 1) }
      )
    end

    def dirty_sheets
      @_dirty_sheets ||= lines.
        each_with_index.
        select { |line, index| line.type != :noop }.
        reduce([]) do |sheets, (_, index)|
          if !sheets.empty? && sheets.last.range.end == index - 1
            sheets[0..-2] + [sheets[-1].extended_to(index)]
          else
            sheets + [
              Sheet.new(
                type: :dirty,
                range: index..index,
              ),
            ]
          end
        end
    end

    def find_boxes_to_elide_within(sheet)
      # binding.pry
      normalized_box_groups_at_decreasing_indentation_levels_within(sheet).
        find do |boxes|
          size_before_eliding = lines[sheet.range].
            reject(&:complete_bookend?).
            size

          size_after_eliding =
            size_before_eliding -
            boxes.sum { |box| box.range.size - 1 }

          # binding.pry

          size_before_eliding > maximum && size_after_eliding <= maximum
        end
    end

    def normalized_box_groups_at_decreasing_indentation_levels_within(sheet)
      box_groups_at_decreasing_indentation_levels_within(sheet).
        map(&method(:filter_out_boxes_fully_contained_in_others)).
        map(&method(:combine_congruent_boxes))
    end

    def box_groups_at_decreasing_indentation_levels_within(sheet)
      boxes_within_sheet = boxes.select do |box|
        box.fully_contained_within?(sheet)
      end

      indentation_level_maximums = boxes_within_sheet.
        map(&:indentation_level).
        select { |indentation_level| indentation_level > 0 }.
        uniq.
        sort.
        reverse

      indentation_level_maximums.map do |indentation_level_maximum|
        boxes_within_sheet.select do |box|
          box.indentation_level >= indentation_level_maximum
        end
      end
    end

    def filter_out_boxes_fully_contained_in_others(boxes)
      sorted_boxes = boxes.sort_by do |box|
        [box.indentation_level, box.range.begin, box.range.end]
      end

      boxes.reject do |box2|
        sorted_boxes.any? do |box1|
          !box1.equal?(box2) && box1.fully_contains?(box2)
        end
      end
    end

    def combine_congruent_boxes(boxes)
      combine(boxes, on: :indentation_level)
    end

    def combine_congruent_sheets(sheets)
      combine(sheets, on: :type)
    end

    def combine(spannables, on:)
      criterion = on
      spannables.reduce([]) do |combined_spannables, spannable|
        if (
          !combined_spannables.empty? &&
          spannable.range.begin <= combined_spannables.last.range.end + 1 &&
          spannable.public_send(criterion) == combined_spannables.last.public_send(criterion)
        )
          combined_spannables[0..-2] + [
            combined_spannables[-1].extended_to(spannable.range.end),
          ]
        else
          combined_spannables + [spannable]
        end
      end
    end

    def boxes
      @_boxes ||= BuildBoxes.call(lines)
    end

    def maximum
      SuperDiff.configuration.diff_elision_maximum
    end

    class BuildSheets
      extend AttrExtras.mixin

      method_object [:dirty_sheets!, :lines!]

      def call
        beginning + middle + ending
      end

      private

      def beginning
        if (
          dirty_sheets.empty? ||
          dirty_sheets.first.range.begin == 0
        )
          []
        else
          [
            Sheet.new(
              type: :clean,
              range: Range.new(
                0,
                dirty_sheets.first.range.begin - 1
              )
            )
          ]
        end
      end

      def middle
        if dirty_sheets.size == 1
          dirty_sheets
        else
          dirty_sheets.
            each_with_index.
            each_cons(2).
            reduce([]) do |sheets, ((sheet1, _), (sheet2, index2))|
              sheets +
              [
                sheet1,
                Sheet.new(
                  type: :clean,
                  range: Range.new(
                    sheet1.range.end + 1,
                    sheet2.range.begin - 1,
                  )
                )
              ] + (
                index2 == dirty_sheets.size - 1 ?
                [sheet2] :
                []
              )
            end
        end
      end

      def ending
        if (
          dirty_sheets.empty? ||
          dirty_sheets.last.range.end >= lines.size - 1
        )
          []
        else
          [
            Sheet.new(
              type: :clean,
              range: Range.new(
                dirty_sheets.last.range.end + 1,
                lines.size - 1
              )
            )
          ]
        end
      end
    end

    class Sheet
      extend AttrExtras.mixin

      rattr_initialize [:type!, :range!]

      def extended_to(new_end)
        self.class.new(type: type, range: range.begin..new_end)
      end

      def padded
        self.class.new(
          type: type,
          range: Range.new(range.begin - padding, range.end + padding)
        )
      end

      def capped_to(beginning, ending)
        new_beginning = range.begin < beginning ? beginning : range.begin
        new_ending = range.end > ending ? ending : range.end
        self.class.new(
          type: type,
          range: Range.new(new_beginning, new_ending),
        )
      end

      private

      def padding
        SuperDiff.configuration.diff_elision_padding || 0
      end
    end

    class BuildBoxes
      def self.call(lines)
        builder = new(lines)
        builder.build
        builder.final_boxes
      end

      attr_reader :final_boxes

      def initialize(lines)
        @lines = lines

        @open_collection_boxes = []
        @final_boxes = []
      end

      def build
        lines.each_with_index do |line, index|
          if line.opens_collection?
            open_new_collection_box(line, index)
          elsif line.closes_collection?
            extend_working_collection_box(index)
            close_working_collection_box
          else
            extend_working_collection_box(index) if open_collection_boxes.any?
            record_item_box(line, index)
          end
        end
      end

      private

      attr_reader :lines, :open_collection_boxes

      def extend_working_collection_box(index)
        open_collection_boxes.last.extend_to(index)
      end

      def close_working_collection_box
        final_boxes << open_collection_boxes.pop
      end

      def open_new_collection_box(line, index)
        open_collection_boxes << Box.new(
          indentation_level: line.indentation_level,
          range: index..index,
        )
      end

      def record_item_box(line, index)
        final_boxes << Box.new(
          indentation_level: line.indentation_level,
          range: index..index,
        )
      end
    end

    class Box
      extend AttrExtras.mixin

      rattr_initialize [:indentation_level!, :range!]

      def fully_contains?(other)
        range.begin <= other.range.begin && range.end >= other.range.end
      end

      def fully_contained_within?(other)
        other.range.begin <= range.begin && other.range.end >= range.end
      end

      def extended_to(new_end)
        dup.tap { |clone| clone.extend_to(new_end) }
      end

      def extend_to(new_end)
        @range = range.begin..new_end
      end
    end

    class Elision
      extend AttrExtras.mixin

      rattr_initialize [:indentation_level!, :children!]

      def type
        :elision
      end

      def prefix
        ""
      end

      def value
        "# ..."
      end

      def elided?
        true
      end

      def add_comma?
        false
      end
    end
  end
end
