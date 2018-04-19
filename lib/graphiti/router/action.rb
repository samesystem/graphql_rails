# frozen_string_literal: true

module Graphiti
  class Router
    # Generic class for any type graphql action. Should not be used directly
    class Action
      include Comparable

      attr_reader :name

      def initialize(name, to:)
        @name = name.to_s.camelize(:lower)
        @to = to
      end

      def options
        { function: ControllerFunction.new(to) }
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
