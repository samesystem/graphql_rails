# frozen_string_literal: true

module GraphqlRails
  class Controller
    # runs {before/around/after}_action controller hooks
    class ActionHooksRunner
      def initialize(action_name:, controller:, graphql_request:)
        @action_name = action_name
        @controller = controller
        @graphql_request = graphql_request
      end

      def call(&block)
        result = nil
        run_action_hooks(:before)
        run_around_action_hooks { result = controller.instance_exec(&block) }
        run_action_hooks(:after)
        result
      end

      private

      attr_reader :action_name, :controller, :graphql_request

      def all_around_hooks
        controller_configuration.action_hooks_for(:around, action_name)
      end

      def controller_configuration
        controller.class.controller_configuration
      end

      def run_around_action_hooks(around_hooks = all_around_hooks, &block)
        return if graphql_request.errors.any?

        pending_around_hooks = around_hooks.clone
        action_hook = pending_around_hooks.shift

        if action_hook
          execute_hook(action_hook) { run_around_action_hooks(pending_around_hooks, &block) }
        else
          yield
        end
      end

      def execute_hook(action_hook, &block)
        return if graphql_request.errors.any?

        if action_hook.anonymous?
          controller.instance_exec(controller, *block, &action_hook.action_proc)
        else
          controller.send(action_hook.name, &block)
        end
      end

      def run_action_hooks(hook_type)
        action_hooks = controller_configuration.action_hooks_for(hook_type, action_name)
        action_hooks.each { |hook| execute_hook(hook) }
      end
    end
  end
end
