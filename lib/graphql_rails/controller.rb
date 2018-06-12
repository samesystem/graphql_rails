# frozen_string_literal: true

require 'active_support/hash_with_indifferent_access'
require 'graphql_rails/controller/configuration'
require 'graphql_rails/controller/request'
require 'graphql_rails/controller/format_results'

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
      call_with_rendering(method_name)

      FormatResults.new(
        graphql_request.object_to_return,
        action_config: self.class.action(method_name),
        params: params,
        graphql_context: graphql_request.context
      ).call
    end

    protected

    attr_reader :graphql_request

    def render(object_or_errors)
      errors = grapqhl_errors_from_render_params(object_or_errors)
      object = errors.empty? ? object_or_errors : nil

      graphql_request.errors = errors
      graphql_request.object_to_return = object
    end

    def params
      @params = HashWithIndifferentAccess.new(graphql_request.params)
    end

    private

    def call_with_rendering(method_name)
      self.class.controller_configuration.before_actions.each { |action_name| send(action_name) }
      response = public_send(method_name)
      render response if graphql_request.no_object_to_return?
    rescue StandardError => error
      render error: error
    end

    def grapqhl_errors_from_render_params(rendering_params)
      return [] unless rendering_params.is_a?(Hash)
      return [] if rendering_params.keys.count != 1

      errors = rendering_params[:error] || rendering_params[:errors]
      Array(errors)
    end
  end
end
