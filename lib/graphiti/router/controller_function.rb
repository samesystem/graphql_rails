# frozen_string_literal: true

require 'active_support/core_ext/string/inflections'

module Graphiti
  class Router
    # graphql resolver which redirects actions to appropriate controller and controller action
    class ControllerFunction < GraphQL::Function
      attr_reader :type

      # accepts path of given format "controller_name#action"
      def initialize(action_path, type: nil, **options)
        @action_path = action_path
        @type = type || default_type
        @module_name = options[:module] || ''
      end

      def call(object, inputs, ctx)
        controller_class.new(object, inputs, ctx).call(action_name)
      end

      def arguments
        controller_class.controller_configuration.arguments_for(action_name).transform_values(&:graphql_input_type)
      end

      private

      attr_reader :action_path, :module_name

      def controller_class
        @controller_class ||= "#{namespaced_controller_name}_controller".classify.constantize
      end

      def namespaced_controller_name
        [module_name, controller_name].reject(&:empty?).join('/')
      end

      def controller_name
        @controller_name ||= action_path.split('#').first
      end

      def action_name
        @action_name ||= action_path.split('#').last
      end

      def default_type
        "#{controller_name.singularize.classify}Type"
      end
    end
  end
end
