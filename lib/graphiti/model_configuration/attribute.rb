# frozen_string_literal: true

module Graphiti
  class ModelConfiguration
    # contains info about single graphql attribute
    class Attribute
      include Comparable

      attr_reader :name, :type

      def initialize(name, type)
        @name = name.to_s
        @type = type
      end

      def <=>(other)
        if other.is_a?(self.class)
          name <=> other.name
        else
          super
        end
      end
    end
  end
end
