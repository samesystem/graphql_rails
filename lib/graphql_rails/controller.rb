# frozen_string_literal: true

require 'active_support/hash_with_indifferent_access'
require_relative 'controller/configuration'
require_relative 'controller/request'

module GraphqlRails
  # base class for all graphql_rails controllers
  class Controller
    class << self
      def before_action(action_name)
        controller_configuration.add_before_action(action_name)
      end

      def action(method_name)
        controller_configuration.action(method_name)
      end

      def controller_configuration
        @controller_configuration ||= Controller::Configuration.new(self)
      end
    end

    def initialize(graphql_request)
      @graphql_request = graphql_request
    end

    def call(method_name)
      self.class.controller_configuration.before_actions.each { |action_name| send(action_name) }

      begin
        response = public_send(method_name)
        render response if graphql_request.no_object_to_return?
      rescue StandardError => error
        render error: error
      end

      graphql_request.object_to_return
    end

    protected

    attr_reader :graphql_request

    def render(object = nil, error: nil, errors: Array(error))
      graphql_request.errors = errors
      graphql_request.object_to_return = object
    end

    def params
      @params = HashWithIndifferentAccess.new(graphql_request.params)
    end
  end
end
