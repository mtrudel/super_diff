require "spec_helper"

# TODO: What if the maximum is 0?
RSpec.describe SuperDiff::TieredLinesElider, type: :unit do
  context "and the gem is configured with :diff_elision_maximum" do
    context "and the line tree contains a section of noops that does not span more than the maximum" do
      it "doesn't elide anything" do
        # Diff:
        #
        #   [
        #     "one",
        #     "two",
        #     "three",
        # -   "four",
        # +   "FOUR",
        #     "six",
        #     "seven",
        #     "eight",
        #   ]

        lines = [
          line(
            type: :noop,
            indentation_level: 0,
            value: %([),
            collection_bookend: :open,
            complete_bookend: :open,
          ),
          line(
            type: :noop,
            indentation_level: 1,
            value: %("one"),
            add_comma: true,
          ),
          line(
            type: :noop,
            indentation_level: 1,
            value: %("two"),
            add_comma: true,
          ),
          line(
            type: :noop,
            indentation_level: 1,
            value: %("three"),
            add_comma: true,
          ),
          line(
            type: :delete,
            indentation_level: 1,
            value: %("four"),
            add_comma: true,
          ),
          line(
            type: :insert,
            indentation_level: 1,
            value: %("FOUR"),
            add_comma: true,
          ),
          line(
            type: :noop,
            indentation_level: 1,
            value: %("five"),
            add_comma: true,
          ),
          line(
            type: :noop,
            indentation_level: 1,
            value: %("six"),
            add_comma: true,
          ),
          line(
            type: :noop,
            indentation_level: 1,
            value: %("seven"),
            add_comma: false,
          ),
          line(
            type: :noop,
            indentation_level: 0,
            value: %(]),
            add_comma: false,
            collection_bookend: :close,
            complete_bookend: :close,
          ),
        ]

        line_tree_with_elisions = with_configuration(
          diff_elision_enabled: true,
          diff_elision_maximum: 3
        ) do
          described_class.call(lines)
        end

        expect(line_tree_with_elisions).to match([
          an_object_having_attributes(
            type: :noop,
            indentation_level: 0,
            value: %([),
            add_comma: false,
            children: [],
            elided?: false,
          ),
          an_object_having_attributes(
            type: :noop,
            indentation_level: 1,
            value: %("one"),
            add_comma: true,
            children: [],
            elided?: false,
          ),
          an_object_having_attributes(
            type: :noop,
            indentation_level: 1,
            value: %("two"),
            add_comma: true,
            children: [],
            elided?: false,
          ),
          an_object_having_attributes(
            type: :noop,
            indentation_level: 1,
            value: %("three"),
            add_comma: true,
            children: [],
            elided?: false,
          ),
          an_object_having_attributes(
            type: :delete,
            indentation_level: 1,
            value: %("four"),
            add_comma: true,
            children: [],
            elided?: false,
          ),
          an_object_having_attributes(
            type: :insert,
            indentation_level: 1,
            value: %("FOUR"),
            add_comma: true,
            children: [],
            elided?: false,
          ),
          an_object_having_attributes(
            type: :noop,
            indentation_level: 1,
            value: %("five"),
            add_comma: true,
            children: [],
            elided?: false,
          ),
          an_object_having_attributes(
            type: :noop,
            indentation_level: 1,
            value: %("six"),
            add_comma: true,
            children: [],
            elided?: false,
          ),
          an_object_having_attributes(
            type: :noop,
            indentation_level: 1,
            value: %("seven"),
            add_comma: false,
            children: [],
            elided?: false,
          ),
          an_object_having_attributes(
            type: :noop,
            indentation_level: 0,
            value: %(]),
            add_comma: false,
            children: [],
            elided?: false,
          ),
        ])
      end
    end

    context "and the line tree contains a section of noops that spans more than the maximum" do
      context "and the tree is one-dimensional" do
        context "and the line tree is just noops" do
          it "doesn't elide anything" do
            # Diff:
            #
            #   [
            #     "one",
            #     "two",
            #     "three",
            #     "four",
            #     "five",
            #     "six",
            #     "seven",
            #     "eight",
            #     "nine",
            #   ]

            lines = [
              line(
                type: :noop,
                indentation_level: 0,
                value: %([),
                collection_bookend: :open,
                complete_bookend: :open,
              ),
              line(
                type: :noop,
                indentation_level: 1,
                value: %("one"),
                add_comma: true,
              ),
              line(
                type: :noop,
                indentation_level: 1,
                value: %("two"),
                add_comma: true,
              ),
              line(
                type: :noop,
                indentation_level: 1,
                value: %("three"),
                add_comma: true,
              ),
              line(
                type: :noop,
                indentation_level: 1,
                value: %("four"),
                add_comma: true,
              ),
              line(
                type: :noop,
                indentation_level: 1,
                value: %("five"),
                add_comma: true,
              ),
              line(
                type: :noop,
                indentation_level: 1,
                value: %("six"),
                add_comma: true,
              ),
              line(
                type: :noop,
                indentation_level: 1,
                value: %("seven"),
                add_comma: true,
              ),
              line(
                type: :noop,
                indentation_level: 1,
                value: %("eight"),
                add_comma: true,
              ),
              line(
                type: :noop,
                indentation_level: 1,
                value: %("nine"),
              ),
              line(
                type: :noop,
                indentation_level: 0,
                value: %(]),
                collection_bookend: :close,
                complete_bookend: :close,
              ),
            ]

            line_tree_with_elisions = with_configuration(
              diff_elision_enabled: true,
              diff_elision_maximum: 3
            ) do
              described_class.call(lines)
            end

            expect(line_tree_with_elisions).to match([
              an_object_having_attributes(
                type: :noop,
                indentation_level: 0,
                value: %([),
                add_comma: false,
                children: [],
                elided?: false,
              ),
              an_object_having_attributes(
                type: :noop,
                indentation_level: 1,
                value: %("one"),
                add_comma: true,
                children: [],
                elided?: false,
              ),
              an_object_having_attributes(
                type: :noop,
                indentation_level: 1,
                value: %("two"),
                add_comma: true,
                children: [],
                elided?: false,
              ),
              an_object_having_attributes(
                type: :noop,
                indentation_level: 1,
                value: %("three"),
                add_comma: true,
                children: [],
                elided?: false,
              ),
              an_object_having_attributes(
                type: :noop,
                indentation_level: 1,
                value: %("four"),
                add_comma: true,
                children: [],
                elided?: false,
              ),
              an_object_having_attributes(
                type: :noop,
                indentation_level: 1,
                value: %("five"),
                add_comma: true,
                children: [],
                elided?: false,
              ),
              an_object_having_attributes(
                type: :noop,
                indentation_level: 1,
                value: %("six"),
                add_comma: true,
                children: [],
                elided?: false,
              ),
              an_object_having_attributes(
                type: :noop,
                indentation_level: 1,
                value: %("seven"),
                add_comma: true,
                children: [],
                elided?: false,
              ),
              an_object_having_attributes(
                type: :noop,
                indentation_level: 1,
                value: %("eight"),
                add_comma: true,
                children: [],
                elided?: false,
              ),
              an_object_having_attributes(
                type: :noop,
                indentation_level: 1,
                value: %("nine"),
                add_comma: false,
                children: [],
                elided?: false,
              ),
              an_object_having_attributes(
                type: :noop,
                indentation_level: 0,
                value: %(]),
                add_comma: false,
                children: [],
                elided?: false,
              ),
            ])
          end
        end

        context "and the line tree contains non-noops in addition to noops" do
          context "and the noops flank the non-noops" do
            context "and :padding is 0" do
              it "elides the beginning of the first noop and the end of the second noop as to put them both at the maximum" do
                # Diff:
                #
                #   [
                #     "one",
                #     "two",
                #     "three",
                #     "four",
                # -   "five",
                # +   "FIVE",
                #     "six",
                #     "seven",
                #     "eight",
                #     "nine",
                #   ]

                lines = [
                  line(
                    type: :noop,
                    indentation_level: 0,
                    value: %([),
                    collection_bookend: :open,
                    complete_bookend: :open,
                  ),
                  line(
                    type: :noop,
                    indentation_level: 1,
                    value: %("one"),
                    add_comma: true,
                  ),
                  line(
                    type: :noop,
                    indentation_level: 1,
                    value: %("two"),
                    add_comma: true,
                  ),
                  line(
                    type: :noop,
                    indentation_level: 1,
                    value: %("three"),
                    add_comma: true,
                  ),
                  line(
                    type: :noop,
                    indentation_level: 1,
                    value: %("four"),
                    add_comma: true,
                  ),
                  line(
                    type: :delete,
                    indentation_level: 1,
                    value: %("five"),
                    add_comma: true,
                  ),
                  line(
                    type: :insert,
                    indentation_level: 1,
                    value: %("FIVE"),
                    add_comma: true,
                  ),
                  line(
                    type: :noop,
                    indentation_level: 1,
                    value: %("six"),
                    add_comma: true,
                  ),
                  line(
                    type: :noop,
                    indentation_level: 1,
                    value: %("seven"),
                    add_comma: true,
                  ),
                  line(
                    type: :noop,
                    indentation_level: 1,
                    value: %("eight"),
                    add_comma: true,
                  ),
                  line(
                    type: :noop,
                    indentation_level: 1,
                    value: %("nine"),
                  ),
                  line(
                    type: :noop,
                    indentation_level: 0,
                    value: %(]),
                    collection_bookend: :close,
                    complete_bookend: :close,
                  ),
                ]

                line_tree_with_elisions = with_configuration(
                  diff_elision_enabled: true,
                  diff_elision_maximum: 3
                ) do
                  described_class.call(lines)
                end

                # Result:
                #
                #   [
                #     # ...
                #     "three",
                #     "four",
                # -   "five",
                # +   "FIVE",
                #     "six",
                #     "seven",
                #     # ...
                #   ]

                expect(line_tree_with_elisions).to match([
                  an_object_having_attributes(
                    type: :noop,
                    indentation_level: 0,
                    value: %([),
                    add_comma: false,
                    children: [],
                    elided?: false,
                  ),
                  an_object_having_attributes(
                    type: :elision,
                    indentation_level: 1,
                    value: "# ...",
                    children: [
                      an_object_having_attributes(
                        type: :noop,
                        indentation_level: 1,
                        value: %("one"),
                        add_comma: true,
                        children: [],
                        elided?: true,
                      ),
                      an_object_having_attributes(
                        type: :noop,
                        indentation_level: 1,
                        value: %("two"),
                        add_comma: true,
                        children: [],
                        elided?: true,
                      ),
                    ],
                    elided?: true,
                  ),
                  an_object_having_attributes(
                    type: :noop,
                    indentation_level: 1,
                    value: %("three"),
                    add_comma: true,
                    children: [],
                    elided?: false,
                  ),
                  an_object_having_attributes(
                    type: :noop,
                    indentation_level: 1,
                    value: %("four"),
                    add_comma: true,
                    children: [],
                    elided?: false,
                  ),
                  an_object_having_attributes(
                    type: :delete,
                    indentation_level: 1,
                    value: %("five"),
                    add_comma: true,
                    children: [],
                    elided?: false,
                  ),
                  an_object_having_attributes(
                    type: :insert,
                    indentation_level: 1,
                    value: %("FIVE"),
                    add_comma: true,
                    children: [],
                    elided?: false,
                  ),
                  an_object_having_attributes(
                    type: :noop,
                    indentation_level: 1,
                    value: %("six"),
                    add_comma: true,
                    children: [],
                    elided?: false,
                  ),
                  an_object_having_attributes(
                    type: :noop,
                    indentation_level: 1,
                    value: %("seven"),
                    add_comma: true,
                    children: [],
                    elided?: false,
                  ),
                  an_object_having_attributes(
                    type: :elision,
                    indentation_level: 1,
                    value: "# ...",
                    children: [
                      an_object_having_attributes(
                        type: :noop,
                        indentation_level: 1,
                        value: %("eight"),
                        add_comma: true,
                        children: [],
                        elided?: true,
                      ),
                      an_object_having_attributes(
                        type: :noop,
                        indentation_level: 1,
                        value: %("nine"),
                        add_comma: false,
                        children: [],
                        elided?: true,
                      ),
                    ],
                    elided?: true,
                  ),
                  an_object_having_attributes(
                    type: :noop,
                    indentation_level: 0,
                    value: %(]),
                    add_comma: false,
                    children: [],
                    elided?: false,
                  ),
                ])
              end
            end

            context "and :padding is more than 0" do
              it "preserves a section around the non-noops from being elided" do
                # Diff:
                #
                #   [
                #     "one",
                #     "two",
                #     "three",
                #     "four",
                # -   "five",
                # +   "FIVE",
                #     "six",
                #     "seven",
                #     "eight",
                #     "nine",
                #   ]

                lines = [
                  line(
                    type: :noop,
                    indentation_level: 0,
                    value: %([),
                    collection_bookend: :open,
                    complete_bookend: :open,
                  ),
                  line(
                    type: :noop,
                    indentation_level: 1,
                    value: %("one"),
                    add_comma: true,
                  ),
                  line(
                    type: :noop,
                    indentation_level: 1,
                    value: %("two"),
                    add_comma: true,
                  ),
                  line(
                    type: :noop,
                    indentation_level: 1,
                    value: %("three"),
                    add_comma: true,
                  ),
                  line(
                    type: :noop,
                    indentation_level: 1,
                    value: %("four"),
                    add_comma: true,
                  ),
                  line(
                    type: :delete,
                    indentation_level: 1,
                    value: %("five"),
                    add_comma: true,
                  ),
                  line(
                    type: :insert,
                    indentation_level: 1,
                    value: %("FIVE"),
                    add_comma: true,
                  ),
                  line(
                    type: :noop,
                    indentation_level: 1,
                    value: %("six"),
                    add_comma: true,
                  ),
                  line(
                    type: :noop,
                    indentation_level: 1,
                    value: %("seven"),
                    add_comma: true,
                  ),
                  line(
                    type: :noop,
                    indentation_level: 1,
                    value: %("eight"),
                    add_comma: true,
                  ),
                  line(
                    type: :noop,
                    indentation_level: 1,
                    value: %("nine"),
                  ),
                  line(
                    type: :noop,
                    indentation_level: 0,
                    value: %(]),
                    collection_bookend: :close,
                    complete_bookend: :close,
                  ),
                ]

                line_tree_with_elisions = with_configuration(
                  diff_elision_enabled: true,
                  diff_elision_maximum: 1,
                  diff_elision_padding: 2
                ) do
                  described_class.call(lines)
                end

                # Result:
                #
                #   [
                #     # ...
                #     "three",
                #     "four",
                # -   "five",
                # +   "FIVE",
                #     "six",
                #     "seven",
                #     # ...
                #   ]

                expect(line_tree_with_elisions).to match([
                  an_object_having_attributes(
                    type: :noop,
                    indentation_level: 0,
                    value: %([),
                    add_comma: false,
                    children: [],
                    elided?: false,
                  ),
                  an_object_having_attributes(
                    type: :elision,
                    indentation_level: 1,
                    value: "# ...",
                    children: [
                      an_object_having_attributes(
                        type: :noop,
                        indentation_level: 1,
                        value: %("one"),
                        add_comma: true,
                        children: [],
                        elided?: true,
                      ),
                      an_object_having_attributes(
                        type: :noop,
                        indentation_level: 1,
                        value: %("two"),
                        add_comma: true,
                        children: [],
                        elided?: true,
                      ),
                    ],
                    elided?: true,
                  ),
                  an_object_having_attributes(
                    type: :noop,
                    indentation_level: 1,
                    value: %("three"),
                    add_comma: true,
                    children: [],
                    elided?: false,
                  ),
                  an_object_having_attributes(
                    type: :noop,
                    indentation_level: 1,
                    value: %("four"),
                    add_comma: true,
                    children: [],
                    elided?: false,
                  ),
                  an_object_having_attributes(
                    type: :delete,
                    indentation_level: 1,
                    value: %("five"),
                    add_comma: true,
                    children: [],
                    elided?: false,
                  ),
                  an_object_having_attributes(
                    type: :insert,
                    indentation_level: 1,
                    value: %("FIVE"),
                    add_comma: true,
                    children: [],
                    elided?: false,
                  ),
                  an_object_having_attributes(
                    type: :noop,
                    indentation_level: 1,
                    value: %("six"),
                    add_comma: true,
                    children: [],
                    elided?: false,
                  ),
                  an_object_having_attributes(
                    type: :noop,
                    indentation_level: 1,
                    value: %("seven"),
                    add_comma: true,
                    children: [],
                    elided?: false,
                  ),
                  an_object_having_attributes(
                    type: :elision,
                    indentation_level: 1,
                    value: "# ...",
                    children: [
                      an_object_having_attributes(
                        type: :noop,
                        indentation_level: 1,
                        value: %("eight"),
                        add_comma: true,
                        children: [],
                        elided?: true,
                      ),
                      an_object_having_attributes(
                        type: :noop,
                        indentation_level: 1,
                        value: %("nine"),
                        add_comma: false,
                        children: [],
                        elided?: true,
                      ),
                    ],
                    elided?: true,
                  ),
                  an_object_having_attributes(
                    type: :noop,
                    indentation_level: 0,
                    value: %(]),
                    add_comma: false,
                    children: [],
                    elided?: false,
                  ),
                ])
              end
            end
          end

          context "and the noops are flanked by the non-noops" do
            context "and :padding is 0" do
              it "elides as much of the middle of the noop as to put it at the maximum" do
                # Diff:
                #
                #   [
                # -   "one",
                # +   "ONE",
                #     "two",
                #     "three",
                #     "four",
                #     "five",
                #     "six",
                #     "seven",
                #     "eight",
                # -   "nine",
                # +   "NINE",
                #   ]

                lines = [
                  line(
                    type: :noop,
                    indentation_level: 0,
                    value: %([),
                    collection_bookend: :open,
                    complete_bookend: :open,
                  ),
                  line(
                    type: :delete,
                    indentation_level: 1,
                    value: %("one"),
                    add_comma: true,
                  ),
                  line(
                    type: :insert,
                    indentation_level: 1,
                    value: %("ONE"),
                    add_comma: true,
                  ),
                  line(
                    type: :noop,
                    indentation_level: 1,
                    value: %("two"),
                    add_comma: true,
                  ),
                  line(
                    type: :noop,
                    indentation_level: 1,
                    value: %("three"),
                    add_comma: true,
                  ),
                  line(
                    type: :noop,
                    indentation_level: 1,
                    value: %("four"),
                    add_comma: true,
                  ),
                  line(
                    type: :noop,
                    indentation_level: 1,
                    value: %("five"),
                    add_comma: true,
                  ),
                  line(
                    type: :noop,
                    indentation_level: 1,
                    value: %("six"),
                    add_comma: true,
                  ),
                  line(
                    type: :noop,
                    indentation_level: 1,
                    value: %("seven"),
                    add_comma: true,
                  ),
                  line(
                    type: :noop,
                    indentation_level: 1,
                    value: %("eight"),
                    add_comma: true,
                  ),
                  line(
                    type: :delete,
                    indentation_level: 1,
                    value: %("nine"),
                  ),
                  line(
                    type: :insert,
                    indentation_level: 1,
                    value: %("NINE"),
                  ),
                  line(
                    type: :noop,
                    indentation_level: 0,
                    value: %(]),
                    collection_bookend: :close,
                    complete_bookend: :close,
                  ),
                ]

                line_tree_with_elisions = with_configuration(
                  diff_elision_enabled: true,
                  diff_elision_maximum: 6,
                ) do
                  described_class.call(lines)
                end

                # Result:
                #
                #   [
                # -   "one",
                # +   "ONE",
                #     "two",
                #     "three",
                #     # ...
                #     "six",
                #     "seven",
                #     "eight",
                # -   "nine",
                # +   "NINE",
                #   ]

                expect(line_tree_with_elisions).to match([
                  an_object_having_attributes(
                    type: :noop,
                    indentation_level: 0,
                    value: %([),
                    add_comma: false,
                    children: [],
                    elided?: false,
                  ),
                  an_object_having_attributes(
                    type: :delete,
                    indentation_level: 1,
                    value: %("one"),
                    add_comma: true,
                    children: [],
                    elided?: false,
                  ),
                  an_object_having_attributes(
                    type: :insert,
                    indentation_level: 1,
                    value: %("ONE"),
                    add_comma: true,
                    children: [],
                    elided?: false,
                  ),
                  an_object_having_attributes(
                    type: :noop,
                    indentation_level: 1,
                    value: %("two"),
                    add_comma: true,
                    children: [],
                    elided?: false,
                  ),
                  an_object_having_attributes(
                    type: :noop,
                    indentation_level: 1,
                    value: %("three"),
                    add_comma: true,
                    children: [],
                    elided?: false,
                  ),
                  an_object_having_attributes(
                    type: :elision,
                    indentation_level: 1,
                    value: "# ...",
                    children: [
                      an_object_having_attributes(
                        type: :noop,
                        indentation_level: 1,
                        value: %("four"),
                        add_comma: true,
                        children: [],
                        elided?: true,
                      ),
                      an_object_having_attributes(
                        type: :noop,
                        indentation_level: 1,
                        value: %("five"),
                        add_comma: true,
                        children: [],
                        elided?: true,
                      ),
                    ],
                    elided?: true,
                  ),
                  an_object_having_attributes(
                    type: :noop,
                    indentation_level: 1,
                    value: %("six"),
                    add_comma: true,
                    children: [],
                    elided?: false,
                  ),
                  an_object_having_attributes(
                    type: :noop,
                    indentation_level: 1,
                    value: %("seven"),
                    add_comma: true,
                    children: [],
                    elided?: false,
                  ),
                  an_object_having_attributes(
                    type: :noop,
                    indentation_level: 1,
                    value: %("eight"),
                    add_comma: true,
                    children: [],
                    elided?: false,
                  ),
                  an_object_having_attributes(
                    type: :delete,
                    indentation_level: 1,
                    value: %("nine"),
                    add_comma: false,
                    children: [],
                    elided?: false,
                  ),
                  an_object_having_attributes(
                    type: :insert,
                    indentation_level: 1,
                    value: %("NINE"),
                    add_comma: false,
                    children: [],
                    elided?: false,
                  ),
                  an_object_having_attributes(
                    type: :noop,
                    indentation_level: 0,
                    value: %(]),
                    add_comma: false,
                    children: [],
                    elided?: false,
                  ),
                ])
              end
            end

            context "and :padding is more than 0" do
              it "preserves a section around the non-noops from being elided" do
                # Diff:
                #
                #   [
                # -   "one",
                # +   "ONE",
                #     "two",
                #     "three",
                #     "four",
                #     "five",
                #     "six",
                #     "seven",
                #     "eight",
                # -   "nine",
                # +   "NINE",
                #   ]

                lines = [
                  line(
                    type: :noop,
                    indentation_level: 0,
                    value: %([),
                    collection_bookend: :open,
                    complete_bookend: :open,
                  ),
                  line(
                    type: :delete,
                    indentation_level: 1,
                    value: %("one"),
                    add_comma: true,
                  ),
                  line(
                    type: :insert,
                    indentation_level: 1,
                    value: %("ONE"),
                    add_comma: true,
                  ),
                  line(
                    type: :noop,
                    indentation_level: 1,
                    value: %("two"),
                    add_comma: true,
                  ),
                  line(
                    type: :noop,
                    indentation_level: 1,
                    value: %("three"),
                    add_comma: true,
                  ),
                  line(
                    type: :noop,
                    indentation_level: 1,
                    value: %("four"),
                    add_comma: true,
                  ),
                  line(
                    type: :noop,
                    indentation_level: 1,
                    value: %("five"),
                    add_comma: true,
                  ),
                  line(
                    type: :noop,
                    indentation_level: 1,
                    value: %("six"),
                    add_comma: true,
                  ),
                  line(
                    type: :noop,
                    indentation_level: 1,
                    value: %("seven"),
                    add_comma: true,
                  ),
                  line(
                    type: :noop,
                    indentation_level: 1,
                    value: %("eight"),
                    add_comma: true,
                  ),
                  line(
                    type: :delete,
                    indentation_level: 1,
                    value: %("nine"),
                  ),
                  line(
                    type: :insert,
                    indentation_level: 1,
                    value: %("NINE"),
                  ),
                  line(
                    type: :noop,
                    indentation_level: 0,
                    value: %(]),
                    collection_bookend: :close,
                    complete_bookend: :close,
                  ),
                ]

                line_tree_with_elisions = with_configuration(
                  diff_elision_enabled: true,
                  diff_elision_maximum: 1,
                  diff_elision_padding: 2,
                ) do
                  described_class.call(lines)
                end

                # Result:
                #
                #   [
                # -   "one",
                # +   "ONE",
                #     "two",
                #     "three",
                #     # ...
                #     "seven",
                #     "eight",
                # -   "nine",
                # +   "NINE",
                #   ]

                expect(line_tree_with_elisions).to match([
                  an_object_having_attributes(
                    type: :noop,
                    indentation_level: 0,
                    value: %([),
                    add_comma: false,
                    children: [],
                    elided?: false,
                  ),
                  an_object_having_attributes(
                    type: :delete,
                    indentation_level: 1,
                    value: %("one"),
                    add_comma: true,
                    children: [],
                    elided?: false,
                  ),
                  an_object_having_attributes(
                    type: :insert,
                    indentation_level: 1,
                    value: %("ONE"),
                    add_comma: true,
                    children: [],
                    elided?: false,
                  ),
                  an_object_having_attributes(
                    type: :noop,
                    indentation_level: 1,
                    value: %("two"),
                    add_comma: true,
                    children: [],
                    elided?: false,
                  ),
                  an_object_having_attributes(
                    type: :noop,
                    indentation_level: 1,
                    value: %("three"),
                    add_comma: true,
                    children: [],
                    elided?: false,
                  ),
                  an_object_having_attributes(
                    type: :elision,
                    indentation_level: 1,
                    value: "# ...",
                    children: [
                      an_object_having_attributes(
                        type: :noop,
                        indentation_level: 1,
                        value: %("four"),
                        add_comma: true,
                        children: [],
                        elided?: true,
                      ),
                      an_object_having_attributes(
                        type: :noop,
                        indentation_level: 1,
                        value: %("five"),
                        add_comma: true,
                        children: [],
                        elided?: true,
                      ),
                      an_object_having_attributes(
                        type: :noop,
                        indentation_level: 1,
                        value: %("six"),
                        add_comma: true,
                        children: [],
                        elided?: true,
                      ),
                    ],
                    elided?: true,
                  ),
                  an_object_having_attributes(
                    type: :noop,
                    indentation_level: 1,
                    value: %("seven"),
                    add_comma: true,
                    children: [],
                    elided?: false,
                  ),
                  an_object_having_attributes(
                    type: :noop,
                    indentation_level: 1,
                    value: %("eight"),
                    add_comma: true,
                    children: [],
                    elided?: false,
                  ),
                  an_object_having_attributes(
                    type: :delete,
                    indentation_level: 1,
                    value: %("nine"),
                    add_comma: false,
                    children: [],
                    elided?: false,
                  ),
                  an_object_having_attributes(
                    type: :insert,
                    indentation_level: 1,
                    value: %("NINE"),
                    add_comma: false,
                    children: [],
                    elided?: false,
                  ),
                  an_object_having_attributes(
                    type: :noop,
                    indentation_level: 0,
                    value: %(]),
                    add_comma: false,
                    children: [],
                    elided?: false,
                  ),
                ])
              end
            end
          end
        end
      end

      context "and the tree is multi-dimensional" do
        context "and the line tree is just noops" do
          it "doesn't elide anything" do
            # Diff:
            #
            #   [
            #     "alpha",
            #     "beta",
            #     [
            #       "proton",
            #       [
            #         "electron",
            #         "photon",
            #         "gluon"
            #       ],
            #       "neutron"
            #     ],
            #     "digamma",
            #     "waw",
            #     "omega"
            #   ]

            lines = [
              line(
                type: :noop,
                indentation_level: 0,
                value: %([),
                collection_bookend: :open,
                complete_bookend: :open,
              ),
              line(
                type: :noop,
                indentation_level: 1,
                value: %("alpha"),
                add_comma: true,
              ),
              line(
                type: :noop,
                indentation_level: 1,
                value: %("beta"),
                add_comma: true,
              ),
              line(
                type: :noop,
                indentation_level: 1,
                value: %([),
                collection_bookend: :open,
              ),
              line(
                type: :noop,
                indentation_level: 2,
                value: %("proton"),
                add_comma: true,
              ),
              line(
                type: :noop,
                indentation_level: 2,
                value: %("["),
                collection_bookend: :open,
              ),
              line(
                type: :noop,
                indentation_level: 3,
                value: %("electron"),
                add_comma: true,
              ),
              line(
                type: :noop,
                indentation_level: 3,
                value: %("photon"),
                add_comma: true,
              ),
              line(
                type: :noop,
                indentation_level: 3,
                value: %("gluon"),
              ),
              line(
                type: :noop,
                indentation_level: 2,
                value: %("]"),
                add_comma: true,
                collection_bookend: :close,
              ),
              line(
                type: :noop,
                indentation_level: 2,
                value: %("neutron"),
              ),
              line(
                type: :noop,
                indentation_level: 1,
                value: %(]),
                add_comma: true,
                collection_bookend: :close,
              ),
              line(
                type: :noop,
                indentation_level: 1,
                value: %("digamma"),
                add_comma: true,
              ),
              line(
                type: :noop,
                indentation_level: 1,
                value: %("waw"),
                add_comma: true,
              ),
              line(
                type: :noop,
                indentation_level: 1,
                value: %("omega"),
              ),
              line(
                type: :noop,
                indentation_level: 0,
                value: %(]),
                collection_bookend: :close,
                complete_bookend: :close,
              ),
            ]

            line_tree_with_elisions = with_configuration(
              diff_elision_enabled: true,
              diff_elision_maximum: 5
            ) do
              described_class.call(lines)
            end

            expect(line_tree_with_elisions).to match([
              an_object_having_attributes(
                type: :noop,
                indentation_level: 0,
                value: %([),
                add_comma: false,
                children: [],
                elided?: false,
              ),
              an_object_having_attributes(
                type: :noop,
                indentation_level: 1,
                value: %("alpha"),
                add_comma: true,
                children: [],
                elided?: false,
              ),
              an_object_having_attributes(
                type: :noop,
                indentation_level: 1,
                value: %("beta"),
                add_comma: true,
                children: [],
                elided?: false,
              ),
              an_object_having_attributes(
                type: :noop,
                indentation_level: 1,
                value: %([),
                add_comma: false,
                children: [],
                elided?: false,
              ),
              an_object_having_attributes(
                type: :noop,
                indentation_level: 2,
                value: %("proton"),
                add_comma: true,
                children: [],
                elided?: false,
              ),
              an_object_having_attributes(
                type: :noop,
                indentation_level: 2,
                value: %("["),
                add_comma: false,
                children: [],
                elided?: false,
              ),
              an_object_having_attributes(
                type: :noop,
                indentation_level: 3,
                value: %("electron"),
                add_comma: true,
                children: [],
                elided?: false,
              ),
              an_object_having_attributes(
                type: :noop,
                indentation_level: 3,
                value: %("photon"),
                add_comma: true,
                children: [],
                elided?: false,
              ),
              an_object_having_attributes(
                type: :noop,
                indentation_level: 3,
                value: %("gluon"),
                add_comma: false,
                children: [],
                elided?: false,
              ),
              an_object_having_attributes(
                type: :noop,
                indentation_level: 2,
                value: %("]"),
                add_comma: true,
                children: [],
                elided?: false,
              ),
              an_object_having_attributes(
                type: :noop,
                indentation_level: 2,
                value: %("neutron"),
                add_comma: false,
                children: [],
                elided?: false,
              ),
              an_object_having_attributes(
                type: :noop,
                indentation_level: 1,
                value: %(]),
                add_comma: true,
                children: [],
                elided?: false,
              ),
              an_object_having_attributes(
                type: :noop,
                indentation_level: 1,
                value: %("digamma"),
                add_comma: true,
                children: [],
                elided?: false,
              ),
              an_object_having_attributes(
                type: :noop,
                indentation_level: 1,
                value: %("waw"),
                add_comma: true,
                children: [],
                elided?: false,
              ),
              an_object_having_attributes(
                type: :noop,
                indentation_level: 1,
                value: %("omega"),
                add_comma: false,
                children: [],
                elided?: false,
              ),
              an_object_having_attributes(
                type: :noop,
                indentation_level: 0,
                value: %(]),
                add_comma: false,
                children: [],
                elided?: false,
              ),
            ])
          end
        end

        context "and the line tree contains non-noops in addition to noops" do
          context "and the only noops are above the only non-noops" do
            context "and the section of noops does not cross indentation level boundaries" do
              context "and :padding is 0" do
                it "represents the smallest portion within the section as an elision (descending into sub-structures if necessary) to fit the whole section under the maximum" do
                  # Diff:
                  #
                  #   [
                  #     "alpha",
                  #     "beta",
                  #     [
                  #       "proton",
                  #       [
                  #         "electron",
                  #         "photon",
                  #         "gluon"
                  #       ],
                  #       "neutron"
                  #     ],
                  # -   "digamma",
                  # +   "waw"
                  #   ]

                  lines = [
                    line(
                      type: :noop,
                      indentation_level: 0,
                      value: %([),
                      collection_bookend: :open,
                      complete_bookend: :open,
                    ),
                    line(
                      type: :noop,
                      indentation_level: 1,
                      value: %("alpha"),
                      add_comma: true,
                    ),
                    line(
                      type: :noop,
                      indentation_level: 1,
                      value: %("beta"),
                      add_comma: true,
                    ),
                    line(
                      type: :noop,
                      indentation_level: 1,
                      value: %([),
                      collection_bookend: :open,
                    ),
                    line(
                      type: :noop,
                      indentation_level: 2,
                      value: %("proton"),
                      add_comma: true,
                    ),
                    line(
                      type: :noop,
                      indentation_level: 2,
                      value: %([),
                      collection_bookend: :open,
                    ),
                    line(
                      type: :noop,
                      indentation_level: 3,
                      value: %("electron"),
                      add_comma: true,
                    ),
                    line(
                      type: :noop,
                      indentation_level: 3,
                      value: %("photon"),
                      add_comma: true,
                    ),
                    line(
                      type: :noop,
                      indentation_level: 3,
                      value: %("gluon"),
                    ),
                    line(
                      type: :noop,
                      indentation_level: 2,
                      value: %(]),
                      add_comma: true,
                      collection_bookend: :close,
                    ),
                    line(
                      type: :noop,
                      indentation_level: 2,
                      value: %("neutron"),
                    ),
                    line(
                      type: :noop,
                      indentation_level: 1,
                      value: %(]),
                      add_comma: true,
                      collection_bookend: :close,
                    ),
                    line(
                      type: :delete,
                      indentation_level: 1,
                      value: %("digamma"),
                      add_comma: true,
                    ),
                    line(
                      type: :insert,
                      indentation_level: 1,
                      value: %("waw"),
                      add_comma: true,
                    ),
                    line(
                      type: :noop,
                      indentation_level: 0,
                      value: %(]),
                      collection_bookend: :close,
                      complete_bookend: :close,
                    ),
                  ]

                  line_tree_with_elisions = with_configuration(
                    diff_elision_enabled: true,
                    diff_elision_maximum: 5
                  ) do
                    described_class.call(lines)
                  end

                  # Result:
                  #
                  #   [
                  #     "alpha",
                  #     "beta",
                  #     [
                  #       # ...
                  #     ],
                  # -   "digamma",
                  # +   "waw"
                  #   ]

                  expect(line_tree_with_elisions).to match([
                    an_object_having_attributes(
                      type: :noop,
                      indentation_level: 0,
                      value: %([),
                      add_comma: false,
                      children: [],
                      elided?: false,
                    ),
                    an_object_having_attributes(
                      type: :noop,
                      indentation_level: 1,
                      value: %("alpha"),
                      add_comma: true,
                      children: [],
                      elided?: false,
                    ),
                    an_object_having_attributes(
                      type: :noop,
                      indentation_level: 1,
                      value: %("beta"),
                      add_comma: true,
                      children: [],
                      elided?: false,
                    ),
                    an_object_having_attributes(
                      type: :noop,
                      indentation_level: 1,
                      value: %([),
                      add_comma: false,
                      children: [],
                      elided?: false,
                    ),
                    an_object_having_attributes(
                      type: :elision,
                      indentation_level: 2,
                      children: [
                        an_object_having_attributes(
                          type: :noop,
                          indentation_level: 2,
                          value: %("proton"),
                          add_comma: true,
                          children: [],
                          elided?: true,
                        ),
                        an_object_having_attributes(
                          type: :noop,
                          indentation_level: 2,
                          value: %([),
                          add_comma: false,
                          children: [],
                          elided?: true,
                        ),
                        an_object_having_attributes(
                          type: :noop,
                          indentation_level: 3,
                          value: %("electron"),
                          add_comma: true,
                          children: [],
                          elided?: true,
                        ),
                        an_object_having_attributes(
                          type: :noop,
                          indentation_level: 3,
                          value: %("photon"),
                          add_comma: true,
                          children: [],
                          elided?: true,
                        ),
                        an_object_having_attributes(
                          type: :noop,
                          indentation_level: 3,
                          value: %("gluon"),
                          add_comma: false,
                          children: [],
                          elided?: true,
                        ),
                        an_object_having_attributes(
                          type: :noop,
                          indentation_level: 2,
                          value: %(]),
                          add_comma: true,
                          children: [],
                          elided?: true,
                        ),
                        an_object_having_attributes(
                          type: :noop,
                          indentation_level: 2,
                          value: %("neutron"),
                          add_comma: false,
                          children: [],
                          elided?: true,
                        ),
                      ],
                      elided?: true,
                    ),
                    an_object_having_attributes(
                      type: :noop,
                      indentation_level: 1,
                      value: %(]),
                      add_comma: true,
                      children: [],
                      elided?: false,
                    ),
                    an_object_having_attributes(
                      type: :delete,
                      indentation_level: 1,
                      value: %("digamma"),
                      add_comma: true,
                      children: [],
                      elided?: false,
                    ),
                    an_object_having_attributes(
                      type: :insert,
                      indentation_level: 1,
                      value: %("waw"),
                      add_comma: true,
                      children: [],
                      elided?: false,
                    ),
                    an_object_having_attributes(
                      type: :noop,
                      indentation_level: 0,
                      value: %(]),
                      add_comma: false,
                      children: [],
                      elided?: false,
                    ),
                  ])
                end
              end

              context "and :padding is more than 0"
            end
          end

          context "and the only noops are below the only non-noops" do
            context "and the section of noops does not cross indentation level boundaries" do
              context "and :padding is 0" do
                it "represents the smallest portion within the section as an elision (descending into sub-structures if necessary) to fit the whole section under the maximum" do
                  # Diff:
                  #
                  #   [
                  # -   "alpha",
                  # +   "beta",
                  #     [
                  #       "proton",
                  #       [
                  #         "electron",
                  #         "photon",
                  #         "gluon"
                  #       ],
                  #       "neutron"
                  #     ],
                  #     "digamma",
                  #     "waw"
                  #   ]

                  lines = [
                    line(
                      type: :noop,
                      indentation_level: 0,
                      value: %([),
                      collection_bookend: :open,
                      complete_bookend: :open,
                    ),
                    line(
                      type: :delete,
                      indentation_level: 1,
                      value: %("alpha"),
                      add_comma: true,
                    ),
                    line(
                      type: :insert,
                      indentation_level: 1,
                      value: %("beta"),
                      add_comma: true,
                    ),
                    line(
                      type: :noop,
                      indentation_level: 1,
                      value: %([),
                      collection_bookend: :open,
                    ),
                    line(
                      type: :noop,
                      indentation_level: 2,
                      value: %("proton"),
                      add_comma: true,
                    ),
                    line(
                      type: :noop,
                      indentation_level: 2,
                      value: %([),
                      collection_bookend: :open,
                    ),
                    line(
                      type: :noop,
                      indentation_level: 3,
                      value: %("electron"),
                      add_comma: true,
                    ),
                    line(
                      type: :noop,
                      indentation_level: 3,
                      value: %("photon"),
                      add_comma: true,
                    ),
                    line(
                      type: :noop,
                      indentation_level: 3,
                      value: %("gluon"),
                    ),
                    line(
                      type: :noop,
                      indentation_level: 2,
                      value: %(]),
                      add_comma: true,
                      collection_bookend: :close,
                    ),
                    line(
                      type: :noop,
                      indentation_level: 2,
                      value: %("neutron"),
                    ),
                    line(
                      type: :noop,
                      indentation_level: 1,
                      value: %(]),
                      add_comma: true,
                      collection_bookend: :close,
                    ),
                    line(
                      type: :noop,
                      indentation_level: 1,
                      value: %("digamma"),
                      add_comma: true,
                    ),
                    line(
                      type: :noop,
                      indentation_level: 1,
                      value: %("waw"),
                      add_comma: true,
                    ),
                    line(
                      type: :noop,
                      indentation_level: 0,
                      value: %(]),
                      collection_bookend: :close,
                      complete_bookend: :close,
                    ),
                  ]

                  line_tree_with_elisions = with_configuration(
                    diff_elision_enabled: true,
                    diff_elision_maximum: 5
                  ) do
                    described_class.call(lines)
                  end

                  # Result:
                  #
                  #   [
                  # -   "alpha",
                  # +   "beta",
                  #     [
                  #       # ...
                  #     ],
                  #     "digamma",
                  #     "waw"
                  #   ]

                  expect(line_tree_with_elisions).to match([
                    an_object_having_attributes(
                      type: :noop,
                      indentation_level: 0,
                      value: %([),
                      add_comma: false,
                      children: [],
                      elided?: false,
                    ),
                    an_object_having_attributes(
                      type: :delete,
                      indentation_level: 1,
                      value: %("alpha"),
                      add_comma: true,
                      children: [],
                      elided?: false,
                    ),
                    an_object_having_attributes(
                      type: :insert,
                      indentation_level: 1,
                      value: %("beta"),
                      add_comma: true,
                      children: [],
                      elided?: false,
                    ),
                    an_object_having_attributes(
                      type: :noop,
                      indentation_level: 1,
                      value: %([),
                      add_comma: false,
                      children: [],
                      elided?: false,
                    ),
                    an_object_having_attributes(
                      type: :elision,
                      indentation_level: 2,
                      children: [
                        an_object_having_attributes(
                          type: :noop,
                          indentation_level: 2,
                          value: %("proton"),
                          add_comma: true,
                          children: [],
                          elided?: true,
                        ),
                        an_object_having_attributes(
                          type: :noop,
                          indentation_level: 2,
                          value: %([),
                          add_comma: false,
                          children: [],
                          elided?: true,
                        ),
                        an_object_having_attributes(
                          type: :noop,
                          indentation_level: 3,
                          value: %("electron"),
                          add_comma: true,
                          children: [],
                          elided?: true,
                        ),
                        an_object_having_attributes(
                          type: :noop,
                          indentation_level: 3,
                          value: %("photon"),
                          add_comma: true,
                          children: [],
                          elided?: true,
                        ),
                        an_object_having_attributes(
                          type: :noop,
                          indentation_level: 3,
                          value: %("gluon"),
                          add_comma: false,
                          children: [],
                          elided?: true,
                        ),
                        an_object_having_attributes(
                          type: :noop,
                          indentation_level: 2,
                          value: %(]),
                          add_comma: true,
                          children: [],
                          elided?: true,
                        ),
                        an_object_having_attributes(
                          type: :noop,
                          indentation_level: 2,
                          value: %("neutron"),
                          add_comma: false,
                          children: [],
                          elided?: true,
                        ),
                      ],
                    ),
                    an_object_having_attributes(
                      type: :noop,
                      indentation_level: 1,
                      value: %(]),
                      add_comma: true,
                      children: [],
                      elided?: false,
                    ),
                    an_object_having_attributes(
                      type: :noop,
                      indentation_level: 1,
                      value: %("digamma"),
                      add_comma: true,
                      children: [],
                      elided?: false,
                    ),
                    an_object_having_attributes(
                      type: :noop,
                      indentation_level: 1,
                      value: %("waw"),
                      add_comma: true,
                      children: [],
                      elided?: false,
                    ),
                    an_object_having_attributes(
                      type: :noop,
                      indentation_level: 0,
                      value: %(]),
                      add_comma: false,
                      children: [],
                      elided?: false,
                    ),
                  ])
                end
              end

              context "and the :padding is more than 0" do
                it "preserves a section around the non-noops from being elided" do
                  # Diff:
                  #
                  #   [
                  # -   "alpha",
                  # +   "beta",
                  #     [
                  #       "proton",
                  #       [
                  #         "electron",
                  #         "photon",
                  #         "gluon"
                  #       ],
                  #       "neutron"
                  #     ],
                  #     "digamma",
                  #     "waw"
                  #   ]

                  lines = [
                    line(
                      type: :noop,
                      indentation_level: 0,
                      value: %([),
                      collection_bookend: :open,
                      complete_bookend: :open,
                    ),
                    line(
                      type: :delete,
                      indentation_level: 1,
                      value: %("alpha"),
                      add_comma: true,
                    ),
                    line(
                      type: :insert,
                      indentation_level: 1,
                      value: %("beta"),
                      add_comma: true,
                    ),
                    line(
                      type: :noop,
                      indentation_level: 1,
                      value: %([),
                      collection_bookend: :open,
                    ),
                    line(
                      type: :noop,
                      indentation_level: 2,
                      value: %("proton"),
                      add_comma: true,
                    ),
                    line(
                      type: :noop,
                      indentation_level: 2,
                      value: %([),
                      collection_bookend: :open,
                    ),
                    line(
                      type: :noop,
                      indentation_level: 3,
                      value: %("electron"),
                      add_comma: true,
                    ),
                    line(
                      type: :noop,
                      indentation_level: 3,
                      value: %("photon"),
                      add_comma: true,
                    ),
                    line(
                      type: :noop,
                      indentation_level: 3,
                      value: %("gluon"),
                    ),
                    line(
                      type: :noop,
                      indentation_level: 2,
                      value: %(]),
                      add_comma: true,
                      collection_bookend: :close,
                    ),
                    line(
                      type: :noop,
                      indentation_level: 2,
                      value: %("neutron"),
                    ),
                    line(
                      type: :noop,
                      indentation_level: 1,
                      value: %(]),
                      add_comma: true,
                      collection_bookend: :close,
                    ),
                    line(
                      type: :noop,
                      indentation_level: 1,
                      value: %("digamma"),
                      add_comma: true,
                    ),
                    line(
                      type: :noop,
                      indentation_level: 1,
                      value: %("waw"),
                      add_comma: true,
                    ),
                    line(
                      type: :noop,
                      indentation_level: 0,
                      value: %(]),
                      collection_bookend: :close,
                      complete_bookend: :close,
                    ),
                  ]

                  line_tree_with_elisions = with_configuration(
                    diff_elision_enabled: true,
                    diff_elision_maximum: 5,
                    diff_elision_padding: 5
                  ) do
                    described_class.call(lines)
                  end

                  # Result:
                  #
                  #   [
                  # -   "alpha",
                  # +   "beta",
                  #     [
                  #       "proton",
                  #       [
                  #         "electron",
                  #         "photon",
                  #         # ...
                  #       ],
                  #       # ...
                  #     ],
                  #     # ...
                  #   ]

                  expect(line_tree_with_elisions).to match([
                    an_object_having_attributes(
                      type: :noop,
                      indentation_level: 0,
                      value: %([),
                      add_comma: false,
                      children: [],
                      elided?: false,
                    ),
                    an_object_having_attributes(
                      type: :delete,
                      indentation_level: 1,
                      value: %("alpha"),
                      add_comma: true,
                      children: [],
                      elided?: false,
                    ),
                    an_object_having_attributes(
                      type: :insert,
                      indentation_level: 1,
                      value: %("beta"),
                      add_comma: true,
                      children: [],
                      elided?: false,
                    ),
                    an_object_having_attributes(
                      type: :noop,
                      indentation_level: 1,
                      value: %([),
                      add_comma: false,
                      children: [],
                      elided?: false,
                    ),
                    an_object_having_attributes(
                      type: :noop,
                      indentation_level: 2,
                      value: %("proton"),
                      add_comma: true,
                      children: [],
                      elided?: false,
                    ),
                    an_object_having_attributes(
                      type: :noop,
                      indentation_level: 2,
                      value: %([),
                      add_comma: false,
                      children: [],
                      elided?: false,
                    ),
                    an_object_having_attributes(
                      type: :noop,
                      indentation_level: 3,
                      value: %("electron"),
                      add_comma: true,
                      children: [],
                      elided?: false,
                    ),
                    an_object_having_attributes(
                      type: :noop,
                      indentation_level: 3,
                      value: %("photon"),
                      add_comma: true,
                      children: [],
                      elided?: false,
                    ),
                    an_object_having_attributes(
                      type: :elision,
                      indentation_level: 3,
                      children: [
                        an_object_having_attributes(
                          type: :noop,
                          indentation_level: 3,
                          value: %("gluon"),
                          add_comma: false,
                          children: [],
                          elided?: true,
                        ),
                      ],
                      elided?: true,
                    ),
                    an_object_having_attributes(
                      type: :noop,
                      indentation_level: 2,
                      value: %(]),
                      add_comma: true,
                      children: [],
                      elided?: false,
                    ),
                    an_object_having_attributes(
                      type: :elision,
                      indentation_level: 2,
                      children: [
                        an_object_having_attributes(
                          type: :noop,
                          indentation_level: 2,
                          value: %("neutron"),
                          add_comma: false,
                          children: [],
                          elided?: true,
                        ),
                      ],
                      elided?: true,
                    ),
                    an_object_having_attributes(
                      type: :noop,
                      indentation_level: 1,
                      value: %(]),
                      add_comma: true,
                      children: [],
                      elided?: false,
                    ),
                    an_object_having_attributes(
                      type: :elision,
                      indentation_level: 1,
                      children: [
                        an_object_having_attributes(
                          type: :noop,
                          indentation_level: 1,
                          value: %("digamma"),
                          add_comma: true,
                          children: [],
                          elided?: true,
                        ),
                        an_object_having_attributes(
                          type: :noop,
                          indentation_level: 1,
                          value: %("waw"),
                          add_comma: true,
                          children: [],
                          elided?: true,
                        ),
                      ],
                      elided?: true,
                    ),
                    an_object_having_attributes(
                      type: :noop,
                      indentation_level: 0,
                      value: %(]),
                      add_comma: false,
                      children: [],
                      elided?: false,
                    ),
                  ])
                end
              end
            end

            context "and the section of noops crosses indentation level boundaries" do
              context "and :padding is 0"

              context "and :padding is more than 0"
            end
          end

          xcontext "and the noops flank the non-noops" do
            context "and the section of noops does not cross indentation level boundaries"

            context "and the section of noops crosses indentation level boundaries" do
              context "assuming that, after the lines that fit completely inside those boundaries are elided, the section of noops is below the maximum" do
                it "only elides lines which fit completely inside the selected sections" do
                  # Diff:
                  #
                  #   [
                  #     "alpha",
                  #     [
                  #       "zeta",
                  #       "eta"
                  #     ],
                  #     "beta",
                  #     [
                  #       "proton",
                  #       "electron",
                  #       [
                  # -       "red",
                  # +       "blue",
                  #         "green"
                  #       ],
                  #       "neutron",
                  #       "charm",
                  #       "up",
                  #       "down"
                  #     ],
                  #     "waw",
                  #     "omega"
                  #   ]

                  lines = [
                    line(
                      type: :noop,
                      indentation_level: 0,
                      value: %([),
                      complete_bookend: :open,
                      collection_bookend: :open,
                    ),
                    line(
                      type: :noop,
                      indentation_level: 1,
                      value: %("alpha"),
                      add_comma: true,
                    ),
                    line(
                      type: :noop,
                      indentation_level: 1,
                      value: %([),
                      collection_bookend: :open,
                    ),
                    line(
                      type: :noop,
                      indentation_level: 2,
                      value: %("zeta"),
                      add_comma: true,
                    ),
                    line(
                      type: :noop,
                      indentation_level: 2,
                      value: %("eta"),
                    ),
                    line(
                      type: :noop,
                      indentation_level: 1,
                      value: %(]),
                      add_comma: true,
                      collection_bookend: :close,
                    ),
                    line(
                      type: :noop,
                      indentation_level: 1,
                      value: %("beta"),
                      add_comma: true,
                    ),
                    line(
                      type: :noop,
                      indentation_level: 1,
                      value: %([),
                      collection_bookend: :open,
                    ),
                    line(
                      type: :noop,
                      indentation_level: 2,
                      value: %("proton"),
                      add_comma: true,
                    ),
                    line(
                      type: :noop,
                      indentation_level: 2,
                      value: %("electron"),
                      add_comma: true,
                    ),
                    line(
                      type: :noop,
                      indentation_level: 2,
                      value: %([),
                      collection_bookend: :open,
                    ),
                    line(
                      type: :delete,
                      indentation_level: 3,
                      value: %("red"),
                      add_comma: true,
                    ),
                    line(
                      type: :insert,
                      indentation_level: 3,
                      value: %("blue"),
                      add_comma: true,
                    ),
                    line(
                      type: :noop,
                      indentation_level: 3,
                      value: %("green"),
                    ),
                    line(
                      type: :noop,
                      indentation_level: 2,
                      value: %(]),
                      add_comma: true,
                      collection_bookend: :close,
                    ),
                    line(
                      type: :noop,
                      indentation_level: 2,
                      value: %("neutron"),
                      add_comma: true,
                    ),
                    line(
                      type: :noop,
                      indentation_level: 2,
                      value: %("charm"),
                      add_comma: true,
                    ),
                    line(
                      type: :noop,
                      indentation_level: 2,
                      value: %("up"),
                      add_comma: true,
                    ),
                    line(
                      type: :noop,
                      indentation_level: 2,
                      value: %("down"),
                    ),
                    line(
                      type: :noop,
                      indentation_level: 1,
                      value: %(]),
                      add_comma: true,
                      collection_bookend: :close,
                    ),
                    line(
                      type: :noop,
                      indentation_level: 1,
                      value: %("waw"),
                      add_comma: true,
                    ),
                    line(
                      type: :noop,
                      indentation_level: 1,
                      value: %("omega"),
                    ),
                    line(
                      type: :noop,
                      indentation_level: 0,
                      value: %(]),
                      collection_bookend: :close,
                      complete_bookend: :close,
                    ),
                  ]

                  line_tree_with_elisions = with_configuration(
                    diff_elision_enabled: true,
                    diff_elision_maximum: 5
                  ) do
                    described_class.call(lines)
                  end

                  expect(line_tree_with_elisions).to match([
                    an_object_having_attributes(
                      type: :noop,
                      indentation_level: 0,
                      value: %([),
                      add_comma: false,
                      children: [],
                      elided?: false,
                    ),
                    an_object_having_attributes(
                      type: :elision,
                      indentation_level: 1,
                      children: [
                        an_object_having_attributes(
                          type: :noop,
                          indentation_level: 1,
                          value: %("alpha"),
                          add_comma: true,
                          children: [],
                          elided?: true,
                        ),
                        an_object_having_attributes(
                          type: :noop,
                          indentation_level: 1,
                          value: %([),
                          add_comma: false,
                          children: [],
                          elided?: true,
                        ),
                        an_object_having_attributes(
                          type: :noop,
                          indentation_level: 2,
                          value: %("zeta"),
                          add_comma: true,
                          children: [],
                          elided?: true,
                        ),
                        an_object_having_attributes(
                          type: :noop,
                          indentation_level: 2,
                          value: %("eta"),
                          add_comma: false,
                          children: [],
                          elided?: true,
                        ),
                        an_object_having_attributes(
                          type: :noop,
                          indentation_level: 1,
                          value: %(]),
                          add_comma: true,
                          children: [],
                          elided?: true,
                        ),
                        an_object_having_attributes(
                          type: :noop,
                          indentation_level: 1,
                          value: %("beta"),
                          add_comma: true,
                          children: [],
                          elided?: true,
                        ),
                      ],
                      elided?: true,
                    ),
                    an_object_having_attributes(
                      type: :noop,
                      indentation_level: 1,
                      value: %([),
                      add_comma: false,
                      children: [],
                      elided?: false,
                    ),
                    an_object_having_attributes(
                      type: :elision,
                      indentation_level: 2,
                      children: [
                        an_object_having_attributes(
                          type: :noop,
                          indentation_level: 2,
                          value: %("proton"),
                          add_comma: true,
                          children: [],
                          elided?: true,
                        ),
                        an_object_having_attributes(
                          type: :noop,
                          indentation_level: 2,
                          value: %("electron"),
                          add_comma: true,
                          children: [],
                          elided?: true,
                        ),
                      ],
                      elided?: true,
                    ),
                    an_object_having_attributes(
                      type: :noop,
                      indentation_level: 2,
                      value: %([),
                      add_comma: false,
                      children: [],
                      elided?: false,
                    ),
                    an_object_having_attributes(
                      type: :delete,
                      indentation_level: 3,
                      value: %("red"),
                      add_comma: true,
                      children: [],
                      elided?: false,
                    ),
                    an_object_having_attributes(
                      type: :insert,
                      indentation_level: 3,
                      value: %("blue"),
                      add_comma: true,
                      children: [],
                      elided?: false,
                    ),
                    an_object_having_attributes(
                      type: :elision,
                      indentation_level: 3,
                      children: [
                        an_object_having_attributes(
                          type: :noop,
                          indentation_level: 3,
                          value: %("green"),
                          add_comma: false,
                          children: [],
                          elided?: true,
                        ),
                      ],
                      elided?: true,
                    ),
                    an_object_having_attributes(
                      type: :noop,
                      indentation_level: 2,
                      value: %(]),
                      add_comma: true,
                      children: [],
                      elided?: false,
                    ),
                    an_object_having_attributes(
                      type: :elision,
                      indentation_level: 2,
                      children: [
                        an_object_having_attributes(
                          type: :noop,
                          indentation_level: 2,
                          value: %("neutron"),
                          add_comma: true,
                          children: [],
                          elided?: true,
                        ),
                        an_object_having_attributes(
                          type: :noop,
                          indentation_level: 2,
                          value: %("charm"),
                          add_comma: true,
                          children: [],
                          elided?: true,
                        ),
                        an_object_having_attributes(
                          type: :noop,
                          indentation_level: 2,
                          value: %("up"),
                          add_comma: true,
                          children: [],
                          elided?: true,
                        ),
                        an_object_having_attributes(
                          type: :noop,
                          indentation_level: 2,
                          value: %("down"),
                          add_comma: false,
                          children: [],
                          elided?: true,
                        ),
                      ],
                      elided?: true,
                    ),
                    an_object_having_attributes(
                      type: :noop,
                      indentation_level: 1,
                      value: %(]),
                      add_comma: true,
                      children: [],
                      elided?: false,
                    ),
                    an_object_having_attributes(
                      type: :elision,
                      indentation_level: 1,
                      children: [
                        an_object_having_attributes(
                          type: :noop,
                          indentation_level: 1,
                          value: %("waw"),
                          add_comma: true,
                          children: [],
                          elided?: true,
                        ),
                        an_object_having_attributes(
                          type: :noop,
                          indentation_level: 1,
                          value: %("omega"),
                          add_comma: false,
                          children: [],
                          elided?: true,
                        ),
                      ],
                      elided?: true,
                    ),
                    an_object_having_attributes(
                      type: :noop,
                      indentation_level: 0,
                      value: %(]),
                      add_comma: false,
                      children: [],
                      elided?: false,
                    ),
                  ])
                end
              end

              context "when, after the lines that fit completely inside those boundaries are elided, the section of noops is still above the maximum" do
                it "elides the lines as much as possible" do
                  # Before eliding:
                  #
                  #   [
                  #     "alpha",
                  #     [
                  #       "beta",
                  #       "gamma"
                  #     ],
                  #     "pi",
                  #     [
                  #       [
                  # -       "red",
                  # +       "blue"
                  #       ]
                  #     ]
                  #   ]

                  lines = [
                    line(
                      type: :noop,
                      indentation_level: 0,
                      value: %([),
                      complete_bookend: :open,
                      collection_bookend: :open,
                    ),
                    line(
                      type: :noop,
                      indentation_level: 1,
                      value: %("alpha"),
                      add_comma: true,
                    ),
                    line(
                      type: :noop,
                      indentation_level: 1,
                      value: %([),
                      collection_bookend: :open,
                    ),
                    line(
                      type: :noop,
                      indentation_level: 2,
                      value: %("beta"),
                      add_comma: true,
                    ),
                    line(
                      type: :noop,
                      indentation_level: 2,
                      value: %("gamma"),
                      add_comma: false,
                    ),
                    line(
                      type: :noop,
                      indentation_level: 1,
                      value: %(]),
                      collection_bookend: :close,
                    ),
                    line(
                      type: :noop,
                      indentation_level: 1,
                      value: %("pi"),
                      add_comma: true,
                    ),
                    line(
                      type: :noop,
                      indentation_level: 1,
                      value: %([),
                      collection_bookend: :open,
                    ),
                    line(
                      type: :noop,
                      indentation_level: 2,
                      value: %([),
                      collection_bookend: :open,
                    ),
                    line(
                      type: :delete,
                      indentation_level: 3,
                      value: %("red"),
                      add_comma: true,
                    ),
                    line(
                      type: :insert,
                      indentation_level: 3,
                      value: %("blue"),
                      add_comma: false,
                    ),
                    line(
                      type: :noop,
                      indentation_level: 2,
                      value: %(]),
                      collection_bookend: :close,
                    ),
                    line(
                      type: :noop,
                      indentation_level: 1,
                      value: %(]),
                      collection_bookend: :close,
                    ),
                    line(
                      type: :noop,
                      indentation_level: 0,
                      value: %(]),
                      collection_bookend: :close,
                    ),
                  ]

                  line_tree_with_elisions = with_configuration(
                    diff_elision_enabled: true,
                    diff_elision_maximum: 5
                  ) do
                    described_class.call(lines)
                  end

                  # After eliding:
                  #
                  #   [
                  #     # ...
                  #     [
                  #       [
                  # -       "red",
                  # +       "blue"
                  #       ]
                  #     ]
                  #   ]

                  expect(line_tree_with_elisions).to match([
                    an_object_having_attributes(
                      type: :noop,
                      indentation_level: 0,
                      value: %([),
                      complete_bookend: :open,
                      collection_bookend: :open,
                      children: [],
                      elided: false,
                    ),
                    an_object_having_attributes(
                      type: :elision,
                      indentation_level: 1,
                      children: [
                        an_object_having_attributes(
                          type: :noop,
                          indentation_level: 1,
                          value: %("alpha"),
                          add_comma: true,
                          children: [],
                          elided: true,
                        ),
                        an_object_having_attributes(
                          type: :noop,
                          indentation_level: 1,
                          value: %([),
                          collection_bookend: :open,
                          children: [],
                          elided: true,
                        ),
                        an_object_having_attributes(
                          type: :noop,
                          indentation_level: 2,
                          value: %("beta"),
                          add_comma: true,
                          children: [],
                          elided: true,
                        ),
                        an_object_having_attributes(
                          type: :noop,
                          indentation_level: 2,
                          value: %("gamma"),
                          add_comma: false,
                          children: [],
                          elided: true,
                        ),
                        an_object_having_attributes(
                          type: :noop,
                          indentation_level: 1,
                          value: %(]),
                          collection_bookend: :close,
                          children: [],
                          elided: true,
                        ),
                        an_object_having_attributes(
                          type: :noop,
                          indentation_level: 1,
                          value: %("pi"),
                          add_comma: true,
                          children: [],
                          elided: true,
                        ),
                      ]
                    ),
                    an_object_having_attributes(
                      type: :noop,
                      indentation_level: 1,
                      value: %([),
                      collection_bookend: :open,
                      children: [],
                      elided: false,
                    ),
                    an_object_having_attributes(
                      type: :noop,
                      indentation_level: 2,
                      value: %([),
                      collection_bookend: :open,
                      children: [],
                      elided: false,
                    ),
                    an_object_having_attributes(
                      type: :delete,
                      indentation_level: 3,
                      value: %("red"),
                      add_comma: true,
                      children: [],
                      elided: false,
                    ),
                    an_object_having_attributes(
                      type: :insert,
                      indentation_level: 3,
                      value: %("blue"),
                      add_comma: false,
                      children: [],
                      elided: false,
                    ),
                    an_object_having_attributes(
                      type: :noop,
                      indentation_level: 2,
                      value: %(]),
                      collection_bookend: :close,
                      children: [],
                      elided: false,
                    ),
                    an_object_having_attributes(
                      type: :noop,
                      indentation_level: 1,
                      value: %(]),
                      collection_bookend: :close,
                      children: [],
                      elided: false,
                    ),
                    an_object_having_attributes(
                      type: :noop,
                      indentation_level: 0,
                      value: %(]),
                      collection_bookend: :close,
                      children: [],
                      elided: false,
                    ),
                  ])
                end
              end
            end
          end

          xcontext "and the noops are flanked by the non-noops" do
            context "and the section of noops does not cross indentation level boundaries"

            context "and the section of noops crosses indentation level boundaries"
          end
        end
      end

      xcontext "and within the noops there is a long string of lines on the same level and one level deeper" do
        it "not only elides the deeper level but also part of the long string as well to reach the max" do
          # Diff:
          #
          #   [
          # -   "0"
          #     "1",
          #     "2",
          #     "3",
          #     "4",
          #     "5",
          #     "6",
          #     "7",
          #     "8",
          #     {
          #       foo: "bar",
          #       baz: "qux"
          #     },
          # +   "9"
          #   ]
        end
      end
    end

    xcontext "and padding around the non-noops is used to determine that section" do
      context "and the tree is multi-dimensional" do
        context "and the section of noops does not cross indentation level boundaries" do
          it "represents the smallest portion within the section as an elision (descending into sub-structures if necessary) to fit the whole section under the maximum" do
            # Diff:
            #
            #   [
            #     "alpha",
            #     "beta",
            #     [
            #       "proton",
            #       [
            #         "electron",
            #         "photon",
            #         "gluon"
            #       ],
            #       "neutron"
            #     ],
            # -   "digamma",
            # +   "waw",
            #     "omega"
            #   ]

            lines = [
              line(
                type: :noop,
                indentation_level: 0,
                value: %([),
                collection_bookend: :open,
                complete_bookend: :open,
              ),
              line(
                type: :noop,
                indentation_level: 1,
                value: %("alpha"),
                add_comma: true,
              ),
              line(
                type: :noop,
                indentation_level: 1,
                value: %("beta"),
                add_comma: true,
              ),
              line(
                type: :noop,
                indentation_level: 1,
                value: %([),
                collection_bookend: :open,
              ),
              line(
                type: :noop,
                indentation_level: 2,
                value: %("proton"),
                add_comma: true,
              ),
              line(
                type: :noop,
                indentation_level: 2,
                value: %("["),
                collection_bookend: :open,
              ),
              line(
                type: :noop,
                indentation_level: 3,
                value: %("electron"),
                add_comma: true,
              ),
              line(
                type: :noop,
                indentation_level: 3,
                value: %("photon"),
                add_comma: true,
              ),
              line(
                type: :noop,
                indentation_level: 3,
                value: %("gluon"),
              ),
              line(
                type: :noop,
                indentation_level: 2,
                value: %("]"),
                add_comma: true,
                collection_bookend: :close,
              ),
              line(
                type: :noop,
                indentation_level: 2,
                value: %("neutron"),
              ),
              line(
                type: :noop,
                indentation_level: 1,
                value: %(]),
                add_comma: true,
                collection_bookend: :close,
              ),
              line(
                type: :delete,
                indentation_level: 1,
                value: %("digamma"),
                add_comma: true,
              ),
              line(
                type: :insert,
                indentation_level: 1,
                value: %("waw"),
                add_comma: true,
              ),
              line(
                type: :noop,
                indentation_level: 1,
                value: %("omega"),
              ),
              line(
                type: :noop,
                indentation_level: 0,
                value: %(]),
                collection_bookend: :close,
                complete_bookend: :close,
              ),
            ]

            line_tree_with_elisions = with_configuration(
              diff_elision_enabled: true,
              diff_elision_maximum: 5,
              diff_elision_padding: 1
            ) do
              described_class.call(lines)
            end

            expect(line_tree_with_elisions).to match([
              an_object_having_attributes(
                type: :noop,
                indentation_level: 0,
                value: %([),
                add_comma: false,
                children: [],
                elided?: false,
              ),
              an_object_having_attributes(
                type: :noop,
                indentation_level: 1,
                value: %("alpha"),
                add_comma: true,
                children: [],
                elided?: false,
              ),
              an_object_having_attributes(
                type: :noop,
                indentation_level: 1,
                value: %("beta"),
                add_comma: true,
                children: [],
                elided?: false,
              ),
              an_object_having_attributes(
                type: :noop,
                indentation_level: 1,
                value: %([),
                add_comma: false,
                children: [],
                elided?: false,
              ),
              an_object_having_attributes(
                type: :elision,
                indentation_level: 2,
                children: [
                  an_object_having_attributes(
                    type: :noop,
                    indentation_level: 2,
                    value: %("proton"),
                    add_comma: true,
                    children: [],
                    elided?: true,
                  ),
                  an_object_having_attributes(
                    type: :noop,
                    indentation_level: 2,
                    value: %("["),
                    add_comma: false,
                    children: [],
                    elided?: true,
                  ),
                  an_object_having_attributes(
                    type: :noop,
                    indentation_level: 3,
                    value: %("electron"),
                    add_comma: true,
                    children: [],
                    elided?: true,
                  ),
                  an_object_having_attributes(
                    type: :noop,
                    indentation_level: 3,
                    value: %("photon"),
                    add_comma: true,
                    children: [],
                    elided?: true,
                  ),
                  an_object_having_attributes(
                    type: :noop,
                    indentation_level: 3,
                    value: %("gluon"),
                    add_comma: false,
                    children: [],
                    elided?: true,
                  ),
                  an_object_having_attributes(
                    type: :noop,
                    indentation_level: 2,
                    value: %("]"),
                    add_comma: true,
                    children: [],
                    elided?: true,
                  ),
                  an_object_having_attributes(
                    type: :noop,
                    indentation_level: 2,
                    value: %("neutron"),
                    add_comma: false,
                    children: [],
                    elided?: true,
                  ),
                ],
              ),
              an_object_having_attributes(
                type: :noop,
                indentation_level: 1,
                value: %(]),
                add_comma: true,
                children: [],
                elided?: false,
              ),
              an_object_having_attributes(
                type: :delete,
                indentation_level: 1,
                value: %("digamma"),
                add_comma: true,
                children: [],
                elided?: false,
              ),
              an_object_having_attributes(
                type: :insert,
                indentation_level: 1,
                value: %("waw"),
                add_comma: true,
                children: [],
                elided?: false,
              ),
              an_object_having_attributes(
                type: :noop,
                indentation_level: 1,
                value: %("omega"),
                add_comma: false,
                children: [],
                elided?: false,
              ),
              an_object_having_attributes(
                type: :noop,
                indentation_level: 0,
                value: %(]),
                add_comma: false,
                children: [],
                elided?: false,
              ),
            ])
          end
        end

        context "and the section of noops crosses indentation level boundaries" do
          it "only elides lines which fit completely inside the selected sections" do
            # Input diff:
            #
            #   [
            #     "alpha",
            #     [
            #       "zeta",
            #       "eta"
            #     ],
            #     "beta",
            #     [
            #       "proton",
            #       "electron",
            #       [
            # -       "red",
            # +       "blue",
            #         "green"
            #       ],
            #       "neutron",
            #       "charm",
            #       "up",
            #       "down"
            #     ],
            #     "waw",
            #     "omega"
            #   ]

            lines = [
              line(
                type: :noop,
                indentation_level: 0,
                value: %([),
                complete_bookend: :open,
                collection_bookend: :open,
              ),
              line(
                type: :noop,
                indentation_level: 1,
                value: %("alpha"),
                add_comma: true,
              ),
              line(
                type: :noop,
                indentation_level: 1,
                value: %([),
                collection_bookend: :open,
              ),
              line(
                type: :noop,
                indentation_level: 2,
                value: %("zeta"),
                add_comma: true,
              ),
              line(
                type: :noop,
                indentation_level: 2,
                value: %("eta"),
              ),
              line(
                type: :noop,
                indentation_level: 1,
                value: %(]),
                add_comma: true,
                collection_bookend: :close,
              ),
              line(
                type: :noop,
                indentation_level: 1,
                value: %("beta"),
                add_comma: true,
              ),
              line(
                type: :noop,
                indentation_level: 1,
                value: %([),
                collection_bookend: :open,
              ),
              line(
                type: :noop,
                indentation_level: 2,
                value: %("proton"),
                add_comma: true,
              ),
              line(
                type: :noop,
                indentation_level: 2,
                value: %("electron"),
                add_comma: true,
              ),
              line(
                type: :noop,
                indentation_level: 2,
                value: %([),
                collection_bookend: :open,
              ),
              line(
                type: :delete,
                indentation_level: 3,
                value: %("red"),
                add_comma: true,
              ),
              line(
                type: :insert,
                indentation_level: 3,
                value: %("blue"),
                add_comma: true,
              ),
              line(
                type: :noop,
                indentation_level: 3,
                value: %("green"),
              ),
              line(
                type: :noop,
                indentation_level: 2,
                value: %(]),
                add_comma: true,
                collection_bookend: :close,
              ),
              line(
                type: :noop,
                indentation_level: 2,
                value: %("neutron"),
                add_comma: true,
              ),
              line(
                type: :noop,
                indentation_level: 2,
                value: %("charm"),
                add_comma: true,
              ),
              line(
                type: :noop,
                indentation_level: 2,
                value: %("up"),
                add_comma: true,
              ),
              line(
                type: :noop,
                indentation_level: 2,
                value: %("down"),
              ),
              line(
                type: :noop,
                indentation_level: 1,
                value: %(]),
                add_comma: true,
                collection_bookend: :close,
              ),
              line(
                type: :noop,
                indentation_level: 1,
                value: %("waw"),
                add_comma: true,
              ),
              line(
                type: :noop,
                indentation_level: 1,
                value: %("omega"),
              ),
              line(
                type: :noop,
                indentation_level: 0,
                value: %(]),
                collection_bookend: :close,
                complete_bookend: :close,
              ),
            ]

            line_tree_with_elisions = with_configuration(
              diff_elision_enabled: true,
              diff_elision_maximum: 5,
              diff_elision_padding: 1
            ) do
              described_class.call(lines)
            end

            # Output diff:
            #
            #   [
            #     # ...
            #     [
            #       # ...
            #       [
            # -       "red",
            # +       "blue",
            #         "green"
            #       ],
            #       # ...
            #     ],
            #     "waw",
            #     "omega"
            #   ]

            expect(line_tree_with_elisions).to match([
              an_object_having_attributes(
                type: :noop,
                indentation_level: 0,
                value: %([),
                add_comma: false,
                children: [],
                elided?: false,
              ),
              an_object_having_attributes(
                type: :elision,
                indentation_level: 1,
                children: [
                  an_object_having_attributes(
                    type: :noop,
                    indentation_level: 1,
                    value: %("alpha"),
                    add_comma: true,
                    children: [],
                    elided?: true,
                  ),
                  an_object_having_attributes(
                    type: :noop,
                    indentation_level: 1,
                    value: %([),
                    add_comma: false,
                    children: [],
                    elided?: true,
                  ),
                  an_object_having_attributes(
                    type: :noop,
                    indentation_level: 2,
                    value: %("zeta"),
                    add_comma: true,
                    children: [],
                    elided?: true,
                  ),
                  an_object_having_attributes(
                    type: :noop,
                    indentation_level: 2,
                    value: %("eta"),
                    add_comma: false,
                    children: [],
                    elided?: true,
                  ),
                  an_object_having_attributes(
                    type: :noop,
                    indentation_level: 1,
                    value: %(]),
                    add_comma: true,
                    children: [],
                    elided?: true,
                  ),
                  an_object_having_attributes(
                    type: :noop,
                    indentation_level: 1,
                    value: %("beta"),
                    add_comma: true,
                    children: [],
                    elided?: true,
                  ),
                ],
                elided?: true,
              ),
              an_object_having_attributes(
                type: :noop,
                indentation_level: 1,
                value: %([),
                add_comma: false,
                children: [],
                elided?: false,
              ),
              an_object_having_attributes(
                type: :elision,
                indentation_level: 2,
                children: [
                  an_object_having_attributes(
                    type: :noop,
                    indentation_level: 2,
                    value: %("proton"),
                    add_comma: true,
                    children: [],
                    elided?: true,
                  ),
                  an_object_having_attributes(
                    type: :noop,
                    indentation_level: 2,
                    value: %("electron"),
                    add_comma: true,
                    children: [],
                    elided?: true,
                  ),
                ],
                elided?: true,
              ),
              an_object_having_attributes(
                type: :noop,
                indentation_level: 2,
                value: %([),
                add_comma: false,
                children: [],
                elided?: false,
              ),
              an_object_having_attributes(
                type: :delete,
                indentation_level: 3,
                value: %("red"),
                add_comma: true,
                children: [],
                elided?: false,
              ),
              an_object_having_attributes(
                type: :insert,
                indentation_level: 3,
                value: %("blue"),
                add_comma: true,
                children: [],
                elided?: false,
              ),
              an_object_having_attributes(
                type: :noop,
                indentation_level: 3,
                value: %("green"),
                add_comma: false,
                children: [],
                elided?: false,
              ),
              an_object_having_attributes(
                type: :noop,
                indentation_level: 2,
                value: %(]),
                add_comma: true,
                children: [],
                elided?: false,
              ),
              an_object_having_attributes(
                type: :elision,
                indentation_level: 2,
                children: [
                  an_object_having_attributes(
                    type: :noop,
                    indentation_level: 2,
                    value: %("neutron"),
                    add_comma: true,
                    children: [],
                    elided?: true,
                  ),
                  an_object_having_attributes(
                    type: :noop,
                    indentation_level: 2,
                    value: %("charm"),
                    add_comma: true,
                    children: [],
                    elided?: true,
                  ),
                  an_object_having_attributes(
                    type: :noop,
                    indentation_level: 2,
                    value: %("up"),
                    add_comma: true,
                    children: [],
                    elided?: true,
                  ),
                  an_object_having_attributes(
                    type: :noop,
                    indentation_level: 2,
                    value: %("down"),
                    add_comma: false,
                    children: [],
                    elided?: true,
                  ),
                ],
                elided?: true,
              ),
              an_object_having_attributes(
                type: :noop,
                indentation_level: 1,
                value: %(]),
                add_comma: true,
                children: [],
                elided?: false,
              ),
              an_object_having_attributes(
                type: :noop,
                indentation_level: 1,
                value: %("waw"),
                add_comma: true,
                children: [],
                elided?: false,
              ),
              an_object_having_attributes(
                type: :noop,
                indentation_level: 1,
                value: %("omega"),
                add_comma: false,
                children: [],
                elided?: false,
              ),
              an_object_having_attributes(
                type: :noop,
                indentation_level: 0,
                value: %(]),
                add_comma: false,
                children: [],
                elided?: false,
              ),
            ])
          end
        end
      end
    end
  end

  def line(**args)
    SuperDiff::Line.new(**args)
  end
end
