# frozen_string_literal: true

require 'active_support/core_ext/string/inflections'
require 'graphql_rails/attribute'
require 'graphql_rails/controller/action_configuration'

module GraphqlRails
  class Controller
    # stores all graphql_rails contoller specific config
    class Configuration
      attr_reader :before_actions

      def initialize(controller)
        @controller = controller
        @before_actions = Set.new
        @action_by_name = {}
      end

      def add_before_action(name)
        before_actions << name
      end

      def action(method_name)
        @action_by_name[method_name.to_s] ||= ActionConfiguration.new
      end

      private

      attr_reader :controller
    end
  end
end
