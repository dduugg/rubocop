# frozen_string_literal: true

module RuboCop
  module Cop
    module Style
      # This cop checks for use of `extend self` or `module_function` in a
      # module.
      #
      # Supported styles are: module_function, extend_self, none.
      #
      # @example EnforcedStyle: module_function (default)
      #   # bad
      #   module Test
      #     extend self
      #     # ...
      #   end
      #
      #   # good
      #   module Test
      #     module_function
      #     # ...
      #   end
      #
      # @example EnforcedStyle: extend_self
      #   # bad
      #   module Test
      #     module_function
      #     # ...
      #   end
      #
      #   # good
      #   module Test
      #     extend self
      #     # ...
      #   end
      #
      # @example EnforcedStyle: none
      #   # bad
      #   module Test
      #     module_function
      #     # ...
      #   end
      #
      #   # bad
      #   module Test
      #     extend self
      #     # ...
      #   end
      #
      # These offenses are not auto-corrected since there are different
      # implications to each approach.
      class ModuleFunction < Cop
        include ConfigurableEnforcedStyle

        MODULE_FUNCTION_MSG =
          'Use `module_function` instead of `extend self`.'.freeze
        EXTEND_SELF_MSG =
          'Use `extend self` instead of `module_function`.'.freeze
        NONE_MSG =
          'Avoid `module_function` and `extend_self`'.freeze

        def_node_matcher :module_function_node?, '(send nil? :module_function)'
        def_node_matcher :extend_self_node?, '(send nil? :extend self)'

        def on_module(node)
          _name, body = *node
          return unless body && body.begin_type?

          each_wrong_style(body.children) do |child_node|
            add_offense(child_node)
          end
        end

        def autocorrect(node)
          lambda do |corrector|
            case style
            when :module_function
              corrector.replace(node.source_range, 'module_function')
            when :extend_self
              corrector.replace(node.source_range, 'extend self')
            when :none
              corrector.remove(node.source_range)
            end
          end
        end

        private

        def each_wrong_style(nodes)
          nodes.each do |node|
            yield node if wrong_style?(node)
          end
        end

        def message(_node)
          case style
          when :module_function
            MODULE_FUNCTION_MSG
          when :extend_self
            EXTEND_SELF_MSG
          when :none
            NONE_MSG
          end
        end

        def wrong_style?(node)
          case style
          when :module_function
            extend_self_node?(node)
          when :extend_self
            module_function_node?(node)
          when :none
            extend_self_node?(node) || module_function_node?(node)
          end
        end
      end
    end
  end
end
