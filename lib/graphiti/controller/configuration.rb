# frozen_string_literal: true

require 'active_support/core_ext/string/inflections'
require 'graphiti/attribute'

module Graphiti
  class Controller
    # stores all graphiti contoller specific config
    class Configuration
      attr_reader :before_actions, :method_specifications

      def initialize(controller)
        @controller = controller
        @before_actions = Set.new
        @method_specifications = {}
      end

      def add_before_action(name)
        before_actions << name
      end

      def add_method_specification(method_name, accepts:, returns: nil)
        stringified_method_name = method_name.to_s
        method_specifications[stringified_method_name] = {
          returns: (returns || default_return_type),
          accepts: accepts
        }
      end

      def default_input_type
        "#{controller.name.sub(/Controller\Z/, '').singularize}Input"
      end

      def arguments_for(method_name)
        arguments = method_specifications.dig(method_name.to_s, :accepts)
        arguments = Array(arguments) unless arguments.is_a?(Array)

        arguments.each.with_object({}) do |argument_name, arguments_by_name|
          arguments_by_name[argument_name] = Attribute.new(argument_name)
        end
      end

      def return_type_for(_method_name)
        default_return_type
      end

      private

      attr_reader :controller

      def types
        GraphQL::Define::TypeDefiner.instance
      end

      def build_argument(*args, **kwargs, &block)
        GraphQL::Argument.from_dsl(*args, **kwargs, &block)
      end

      def default_return_type
        "#{controller.name.sub(/Controller\Z/, '').singularize}Type"
      end
    end
  end
end
