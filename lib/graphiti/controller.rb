# frozen_string_literal: true

require_relative 'controller/configuration'
require_relative 'controller/graphql_request'

module Graphiti
  # base class for all graphiti controllers
  class Controller
    class << self
      def before_action(action_name)
        controller_configuration.add_before_action(action_name)
      end

      def specify(method_name, accepts: [], returns: nil)
        controller_configuration.add_method_specification(method_name, accepts: accepts, returns: returns)
      end

      def controller_configuration
        @controller_configuration ||= Controller::Configuration.new(self)
      end
    end

    def initialize(graphql_request)
      @graphql_request = graphql_request
    end

    def call(method_name)
      self.class.before_actions.each { |action_name| send(action_name) }
      public_send(method_name)
    end

    protected

    attr_reader :graphql_request

    def params
      graphql_request.params
    end
  end
end
