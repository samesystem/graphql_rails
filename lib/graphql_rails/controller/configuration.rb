# frozen_string_literal: true

require 'active_support/core_ext/string/inflections'
require 'graphql_rails/attribute'
require 'graphql_rails/controller/action_configuration'
require 'graphql_rails/controller/before_action_filter'

module GraphqlRails
  class Controller
    # stores all graphql_rails contoller specific config
    class Configuration
      def initialize(controller)
        @controller = controller
        @before_actions = {}
        @action_by_name = {}
      end

      def before_actions_for(action_name)
        before_actions.values.select { |action| action.applicable_for?(action_name) }
      end

      def add_before_action(name, **options)
        symbolized_name = name.to_sym
        before_actions[symbolized_name] = BeforeActionFilter.new(symbolized_name, **options)
      end

      def action(method_name)
        @action_by_name[method_name.to_s] ||= ActionConfiguration.new
      end

      private

      attr_reader :controller, :before_actions
    end
  end
end
