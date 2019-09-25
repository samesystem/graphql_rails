# frozen_string_literal: true

require 'active_support/core_ext/string/inflections'
require 'graphql_rails/errors/error'
require 'graphql_rails/model'
require_relative 'request'

module GraphqlRails
  class Controller
    # analyzes route and extracts controller action related data
    class Action
      class DeprecatedDefaultModelError < GraphqlRails::Error; end

      def initialize(route)
        @route = route
      end

      def return_type
        action_config.return_type || raise_deprecation_error
      end

      def arguments
        action_config.attributes.values
      end

      def controller
        @controller ||= "#{namespaced_controller_name}_controller".classify.constantize
      end

      def name
        @name ||= action_relative_path.split('#').last
      end

      def description
        action_config.description
      end

      private

      attr_reader :route

      def raise_deprecation_error
        message = \
          'Default return types are deprecated. ' \
          "You need to set something like `action(:#{name}).returns('#{namespaced_model_name}')` " \
          "for #{action_relative_path} action manualy"
        raise DeprecatedDefaultModelError, message
      end

      def action_relative_path
        route.relative_path
      end

      def action_config
        controller.controller_configuration.action(name)
      end

      def namespaced_controller_name
        [route.module_name, controller_name].reject(&:empty?).join('/')
      end

      def controller_name
        @controller_name ||= action_relative_path.split('#').first
      end

      def namespaced_model_name
        namespaced_controller_name.singularize.classify
      end
    end
  end
end
