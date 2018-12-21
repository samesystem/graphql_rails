# frozen_string_literal: true

require 'active_support/core_ext/string/inflections'
require 'graphql_rails/attribute'
require 'graphql_rails/controller/action_configuration'
require 'graphql_rails/controller/action_filter'

module GraphqlRails
  class Controller
    # stores all graphql_rails contoller specific config
    class Configuration
      def initialize
        @before_actions = {}
        @around_actions = {}
        @after_actions = {}
        @action_by_name = {}
      end

      def initialize_copy(other)
        super
        @before_actions = other.instance_variable_get(:@before_actions).dup
        @around_actions = other.instance_variable_get(:@around_actions).dup
        @after_actions = other.instance_variable_get(:@after_actions).dup
        @action_by_name = other.instance_variable_get(:@action_by_name).dup
      end

      def before_actions_for(action_name)
        action_filters_for(action_name, before_actions)
      end

      def around_actions_for(action_name)
        action_filters_for(action_name, around_actions)
      end

      def after_actions_for(action_name)
        action_filters_for(action_name, after_actions)
      end

      def add_around_action(name, **options)
        add_action(name, around_actions, **options)
      end

      def add_before_action(name, **options)
        add_action(name, before_actions, **options)
      end

      def add_after_action(name, **options)
        add_action(name, after_actions, **options)
      end

      def action(method_name)
        @action_by_name[method_name.to_s] ||= ActionConfiguration.new
      end

      private

      attr_reader :before_actions, :around_actions, :after_actions

      def action_filters_for(action_name, action_filters)
        action_filters.values.select { |filter| filter.applicable_for?(action_name) }
      end

      def add_action(name, actions_collection, **options)
        symbolized_name = name.to_sym
        actions_collection[symbolized_name] = ActionFilter.new(symbolized_name, **options)
      end
    end
  end
end
