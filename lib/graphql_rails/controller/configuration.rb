# frozen_string_literal: true

require 'active_support/core_ext/string/inflections'
require 'graphql_rails/attribute'
require 'graphql_rails/controller/action_configuration'
require 'graphql_rails/controller/action_hook'

module GraphqlRails
  class Controller
    # stores all graphql_rails contoller specific config
    class Configuration
      def initialize
        @hooks = {
          before: {},
          after: {},
          around: {}
        }

        @action_by_name = {}
      end

      def initialize_copy(other)
        super

        @action_by_name = other.instance_variable_get(:@action_by_name).transform_values(&:dup)

        hooks_to_copy = other.instance_variable_get(:@hooks)
        @hooks = hooks_to_copy.each.with_object({}) do |(hook_type, type_hooks), new_hooks|
          new_hooks[hook_type] = type_hooks.transform_values(&:dup)
        end
      end

      def action_hooks_for(hook_type, action_name)
        hooks[hook_type].values.select { |hook| hook.applicable_for?(action_name) }
      end

      def add_action_hook(hook_type, name = nil, **options, &block)
        hook_name = name&.to_sym
        hook_key = hook_name || :"anonymous_#{block.hash}"

        hooks[hook_type][hook_key] = \
          ActionHook.new(name: hook_name, **options, &block)
      end

      def action(method_name)
        @action_by_name[method_name.to_s] ||= ActionConfiguration.new
      end

      private

      attr_reader :hooks
    end
  end
end
