# frozen_string_literal: true

require 'graphql_rails/controller/action'
require_relative 'request'
require_relative 'action'

module GraphqlRails
  class Controller
    # graphql resolver which redirects actions to appropriate controller and controller action
    class ControllerFunction < GraphQL::Function
      # accepts path of given format "controller_name#action"
      attr_reader :type

      def initialize(controller:, action_name:, type:)
        @controller = controller
        @action_name = action_name
        @type = type
      end

      def self.from_route(route)
        action = Action.new(route)

        action_function_class(action).new(
          controller: action.controller,
          action_name: action.name,
          type: action.return_type
        )
      end

      def self.action_function_class(action)
        Class.new(self) do
          description(action.description)

          action.arguments.each do |attribute|
            argument(*attribute.function_argument_args)
          end
        end
      end

      def call(object, inputs, ctx)
        request = Request.new(object, inputs, ctx)
        controller.new(request).call(action_name)
      end

      private

      attr_reader :controller, :action_name
    end
  end
end
