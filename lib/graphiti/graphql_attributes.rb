require 'graphql'

module Graphiti
  # contains infor about all attributes associated with single model/class
  class GraphqlAttributes
    # contains info about single graphql attribute
    class Attribute
      include Comparable

      attr_reader :name, :type

      def initialize(name, type)
        @name = name
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

    GRAPHQL_TYPE_MAPPING = {
      int: GraphQL::INT_TYPE,
      float: GraphQL::FLOAT_TYPE,
      string: GraphQL::STRING_TYPE,
      boolean: GraphQL::BOOLEAN_TYPE
    }

    def attributes
      @attributes ||= Set.new
    end

    def add(name, type = nil)
      type ||= GRAPHQL_TYPE_MAPPING[type] || type
      type ||= self.class.type_by_attribute_name(name)

      attributes.add(Attribute.new(name, type))
    end

    def self.type_by_attribute_name(attribute_name)
      case attribute_name
      when 'id', /_id\Z/
        GraphQL::ID_TYPE
      when /title\Z/, /name\Z/
        GraphQL::STRING_TYPE
      when /\?\Z/
        GraphQL::BOOLEAN_TYPE
      else
        raise 'Please specify type for attribute #{attribute_name.inspect}. ' \
              'Example `attribute #{attribute_name}, types.String`'
      end
    end
  end
end
