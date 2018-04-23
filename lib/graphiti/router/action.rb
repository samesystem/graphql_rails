# frozen_string_literal: true

require_relative '../controller/controller_function'

module Graphiti
  class Router
    # Generic class for any type graphql action. Should not be used directly
    class Action
      include Comparable

      attr_reader :name, :controller_action_path

      def initialize(name, to:, **options)
        @name = name.to_s.camelize(:lower)
        @controller_action_path = [options[:module].to_s, to].reject(&:empty?).join('/')
      end

      def options
        {
          function: Controller::ControllerFunction.new(controller_action_path)
        }
      end

      def <=>(other)
        if other.is_a?(Action)
          name <=> other.name
        else
          super
        end
      end
    end
  end
end
