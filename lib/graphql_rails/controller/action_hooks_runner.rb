# frozen_string_literal: true

module GraphqlRails
  class Controller
    # runs {before/around/after}_action controller hooks
    class ActionHooksRunner
      def initialize(action_name:, controller:)
        @action_name = action_name
        @controller = controller
      end

      def call
        run_before_action_hooks
        run_around_actions { yield }.tap do
          run_after_action_hooks
        end
      end

      private

      attr_reader :action_name, :controller

      def all_around_actions
        controller_configuration.around_actions_for(action_name)
      end

      def controller_configuration
        controller.class.controller_configuration
      end

      def run_around_actions(around_actions = all_around_actions, &block)
        pending_around_actions = around_actions.clone
        around_action = pending_around_actions.shift

        if around_action
          controller.send(around_action.name) { run_around_actions(pending_around_actions, &block) }
        else
          yield
        end
      end

      def run_before_action_hooks
        before_actions = controller_configuration.before_actions_for(action_name)
        before_actions.each { |filter| controller.send(filter.name) }
      end

      def run_after_action_hooks
        after_actions = controller_configuration.after_actions_for(action_name)
        after_actions.each { |filter| controller.send(filter.name) }
      end
    end
  end
end
