# frozen_string_literal: true

module RuboCop
  module Cop
    module Rails
      # This cop enforces the use `pick` over `pluck(...).first`.
      #
      # @example
      #   # bad
      #   Model.pluck(:a).first
      #   Model.pluck(:a, :b).first
      #
      #   # good
      #   Model.pick(:a)
      #   Model.pick(:a, :b)
      class Pick < Cop
        extend TargetRailsVersion

        MSG = 'Prefer `pick(%<args>s)` over `pluck(%<args>s).first`.'

        minimum_target_rails_version 6.0

        def_node_matcher :pick_candidate?, <<~PATTERN
          (send (send _ :pluck ...) :first)
        PATTERN

        def on_send(node)
          pick_candidate?(node) do
            range = node.receiver.loc.selector.join(node.loc.selector)
            add_offense(node, location: range)
          end
        end

        def autocorrect(node)
          first_range = node.receiver.source_range.end.join(node.loc.selector)

          lambda do |corrector|
            corrector.remove(first_range)
            corrector.replace(node.receiver.loc.selector, 'pick')
          end
        end

        private

        def message(node)
          format(MSG, args: node.receiver.arguments.map(&:source).join(', '))
        end
      end
    end
  end
end
