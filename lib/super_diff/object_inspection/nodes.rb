module SuperDiff
  module ObjectInspection
    module Nodes
      autoload(
        :AsLinesWhenRenderingToLines,
        "super_diff/object_inspection/nodes/as_lines_when_rendering_to_lines",
      )
      autoload(
        :AsPrefixWhenRenderingToLines,
        "super_diff/object_inspection/nodes/as_prefix_when_rendering_to_lines",
      )
      autoload(
        :AsSingleLine,
        "super_diff/object_inspection/nodes/as_single_line",
      )
      autoload :Base, "super_diff/object_inspection/nodes/base"
      autoload :Inspection, "super_diff/object_inspection/nodes/inspection"
      autoload :Nesting, "super_diff/object_inspection/nodes/nesting"
      autoload :OnlyWhen, "super_diff/object_inspection/nodes/only_when"
      autoload :Text, "super_diff/object_inspection/nodes/text"
      # autoload(
        # :WhenEmpty,
        # "super_diff/object_inspection/nodes/when_empty",
      # )
      # autoload(
        # :WhenNonEmpty,
        # "super_diff/object_inspection/nodes/when_non_empty",
      # )
      autoload(
        :WhenRenderingToLines,
        "super_diff/object_inspection/nodes/when_rendering_to_lines",
      )
      autoload(
        :WhenRenderingToString,
        "super_diff/object_inspection/nodes/when_rendering_to_string",
      )

      def self.registry
        @_registry ||= [
          AsLinesWhenRenderingToLines,
          AsPrefixWhenRenderingToLines,
          AsSingleLine,
          Inspection,
          Nesting,
          OnlyWhen,
          Text,
          # WhenEmpty,
          # WhenNonEmpty,
          WhenRenderingToLines,
          WhenRenderingToString,
        ]
      end
    end
  end
end
