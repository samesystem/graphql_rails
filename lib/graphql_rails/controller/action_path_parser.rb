# frozen_string_literal: true

require 'active_support/core_ext/string/inflections'
require_relative 'request'

module GraphqlRails
  class Controller
    # graphql resolver which redirects actions to appropriate controller and controller action
    class ActionPathParser
      # accepts path of given format "controller_name#action"
      def initialize(action_path, **options)
        @action_path = action_path
        @module_name = options[:module] || ''
      end

      def return_type
        return_type = action.return_type || default_type

        if action.can_return_nil?
          return_type
        else
          return_type.to_non_null_type
        end
      end

      def arguments
        action.attributes.values
      end

      def controller
        @controller ||= "#{namespaced_controller_name}_controller".classify.constantize
      end

      def action_name
        @action_name ||= action_path.split('#').last
      end

      private

      attr_reader :action_path, :module_name

      def action
        controller.controller_configuration.action(action_name)
      end

      def namespaced_controller_name
        [module_name, controller_name].reject(&:empty?).join('/')
      end

      def controller_name
        @controller_name ||= action_path.split('#').first
      end

      def action_model
        model_path = namespaced_controller_name.singularize.classify.split('::')
        model_name = model_path.pop

        while model_path.any?
          begin
            return [model_path, model_name].join('::').constantize
          rescue NameError => err
            raise unless err.message.match?(/uninitialized constant/)
            model_path.pop
          end
        end

        model_name.constantize
      end

      def default_type
        action_model.graphql.graphql_type
      end
    end
  end
end
