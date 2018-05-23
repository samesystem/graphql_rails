# frozen_string_literal: true

require 'active_support/core_ext/string/inflections'
require_relative 'request'

module GraphqlRails
  class Controller
    # analyzes route and extracts controller action related data
    class Action
      def initialize(route)
        @route = route
      end

      def return_type
        action_config.return_type || default_type
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

      private

      attr_reader :route

      def default_inner_return_type
        if action_config.can_return_nil?
          model_graphql_type
        else
          model_graphql_type.to_non_null_type
        end
      end

      def default_type
        type = default_inner_return_type
        type = type.to_list_type.to_non_null_type if route.collection?
        type
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

      def action_model
        namespace = namespaced_controller_name.singularize.classify.split('::')
        model_name = namespace.pop
        model = nil

        while model.nil? && !namespace.empty?
          model = namespaced_model(namespace, model_name)
          namespace.pop
        end

        model || model_name.constantize
      end

      def namespaced_model(namespace, model_name)
        [namespace, model_name].join('::').constantize
      rescue NameError => err
        raise unless err.message.match?(/uninitialized constant/)
        nil
      end

      def model_graphql_type
        action_model.graphql.graphql_type
      end
    end
  end
end
