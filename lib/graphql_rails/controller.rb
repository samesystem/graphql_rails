# frozen_string_literal: true

require 'active_support/hash_with_indifferent_access'
require 'active_support/core_ext/hash'
require 'graphql_rails/controller/configuration'
require 'graphql_rails/controller/request'
require 'graphql_rails/controller/format_results'
require 'graphql_rails/controller/action_hooks_runner'
require 'graphql_rails/controller/log_controller_action'
require 'graphql_rails/controller/relation_decorator'

module GraphqlRails
  # base class for all graphql_rails controllers
  class Controller
    class << self
      def inherited(sublass)
        sublass.instance_variable_set(:@controller_configuration, controller_configuration.dup)
      end

      def before_action(*args, &block)
        controller_configuration.add_action_hook(:before, *args, &block)
      end

      def around_action(*args, &block)
        controller_configuration.add_action_hook(:around, *args, &block)
      end

      def after_action(*args, &block)
        controller_configuration.add_action_hook(:after, *args, &block)
      end

      def action(action_name)
        controller_configuration.action(action_name)
      end

      def controller_configuration
        @controller_configuration ||= Controller::Configuration.new
      end
    end

    attr_reader :action_name

    def initialize(graphql_request)
      @graphql_request = graphql_request
    end

    def call(method_name)
      @action_name = method_name
      with_controller_action_logging do
        call_with_rendering
        format_controller_results
      end
    ensure
      @action_name = nil
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
      @params ||= graphql_request.params.deep_transform_keys { |key| key.to_s.underscore }.with_indifferent_access
    end

    def decorate(object, with:)
      decorator = with
      if Controller::RelationDecorator.decorates?(object)
        Controller::RelationDecorator.new(
          relation: object, decorator: decorator
        )
      elsif object.nil?
        nil
      else
        decorator.new(object)
      end
    end

    private

    def call_with_rendering
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

    def with_controller_action_logging(&block)
      LogControllerAction.call(
        controller_name: self.class.name,
        action_name: action_name,
        params: params,
        graphql_request: graphql_request,
        &block
      )
    end

    def format_controller_results
      FormatResults.new(
        graphql_request.object_to_return,
        action_config: self.class.action(action_name),
        params: params,
        graphql_context: graphql_request.context
      ).call
    end
  end
end
