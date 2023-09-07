# frozen_string_literal: true

require 'active_support/core_ext/string/inflections'
require 'graphql_rails/controller/action_configuration'
require 'graphql_rails/controller/action_hook'
require 'graphql_rails/errors/error'

module GraphqlRails
  class Controller
    # stores all graphql_rails controller specific config
    class Configuration
      class InvalidActionConfiguration < GraphqlRails::Error; end

      LIB_REGEXP = %r{/graphql_rails/lib/}

      attr_reader :action_by_name, :error_handlers

      def initialize(controller)
        @controller = controller
        @hooks = {
          before: {},
          after: {},
          around: {}
        }

        @action_by_name = {}
        @action_default = nil
        @error_handlers = {}
      end

      def initialize_copy(other)
        super

        @action_by_name = other.instance_variable_get(:@action_by_name).transform_values(&:dup)

        hooks_to_copy = other.instance_variable_get(:@hooks)
        @hooks = hooks_to_copy.each.with_object({}) do |(hook_type, type_hooks), new_hooks|
          new_hooks[hook_type] = type_hooks.transform_values(&:dup)
        end
      end

      def dup_with(controller:)
        dup.tap do |new_config|
          new_config.instance_variable_set(:@controller, controller)
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

      def add_error_handler(error, with:, &block)
        @error_handlers[error] = with || block
      end

      def action_default
        @action_default ||= ActionConfiguration.new(name: :default, controller: nil)
        yield(@action_default) if block_given?
        @action_default
      end

      def action(method_name)
        action_name = method_name.to_s.underscore
        @action_by_name[action_name] ||= action_default.dup_with(
          name: action_name,
          controller: controller,
          defined_at: dynamic_source_location
        )
        yield(@action_by_name[action_name]) if block_given?
        @action_by_name[action_name]
      end

      def action_config(method_name)
        action_name = method_name.to_s.underscore
        @action_by_name.fetch(action_name) { raise_invalid_config_error(action_name) }
      end

      def model(model = nil)
        action_default.model(model)
      end

      private

      attr_reader :hooks, :controller

      def dynamic_source_location
        project_trace = \
          caller
          .dup
          .drop_while { |path| !path.match?(LIB_REGEXP) }
          .drop_while { |path| path.match?(LIB_REGEXP) }

        project_trace.first
      end

      def raise_invalid_config_error(action_name)
        error_message = \
          "Missing action configuration for #{controller}##{action_name}. " \
          "Please define it with `action(:#{action_name})`."

        raise InvalidActionConfiguration, error_message
      end
    end
  end
end
