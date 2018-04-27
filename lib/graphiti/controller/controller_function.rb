# frozen_string_literal: true

require 'graphiti/controller/action_path_parser'
require_relative 'request'

module Graphiti
  class Controller
    # graphql resolver which redirects actions to appropriate controller and controller action
    class ControllerFunction < GraphQL::Function
      # accepts path of given format "controller_name#action"
      attr_reader :type

      def initialize(controller, action_name, return_type)
        @controller = controller
        @action_name = action_name
        @type = return_type
      end

      def self.build(action_path, **options)
        action_parser = ActionPathParser.new(action_path, **options)

        action_function = Class.new(self) do
          action_parser.arguments.each do |action_attribute|
            argument(action_attribute.field_name, action_attribute.graphql_field_type)
          end
        end

        action_function.new(action_parser.controller, action_parser.action_name, action_parser.return_type)
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
