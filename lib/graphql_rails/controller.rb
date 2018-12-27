# frozen_string_literal: true

require 'active_support/hash_with_indifferent_access'
require 'graphql_rails/controller/configuration'
require 'graphql_rails/controller/request'
require 'graphql_rails/controller/format_results'
require 'graphql_rails/controller/action_hooks_runner'

module GraphqlRails
  # base class for all graphql_rails controllers
  class Controller
    class << self
      def inherited(sublass)
        sublass.instance_variable_set(:@controller_configuration, controller_configuration.dup)
      end

      def before_action(*args)
        controller_configuration.add_before_action(*args)
      end

      def around_action(*args)
        controller_configuration.add_around_action(*args)
      end

      def after_action(*args)
        controller_configuration.add_after_action(*args)
      end

      def action(action_name)
        controller_configuration.action(action_name)
      end

      def controller_configuration
        @controller_configuration ||= Controller::Configuration.new
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
      errors = graphql_errors_from_render_params(object_or_errors)
      object = errors.empty? ? object_or_errors : nil

      graphql_request.errors = errors
      graphql_request.object_to_return = object
    end

    def params
      @params = HashWithIndifferentAccess.new(graphql_request.params)
    end

    private

    def call_with_rendering(action_name)
      hooks_runner = ActionHooksRunner.new(action_name: action_name, controller: self)
      response = hooks_runner.call { public_send(action_name) }

      render response if graphql_request.no_object_to_return?
    rescue StandardError => error
      render error: error
    end

    def graphql_errors_from_render_params(rendering_params)
      return [] unless rendering_params.is_a?(Hash)
      return [] if rendering_params.keys.count != 1

      errors = rendering_params[:error] || rendering_params[:errors]
      Array(errors)
    end
  end
end
