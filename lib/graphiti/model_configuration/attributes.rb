# frozen_string_literal: true

require 'graphql'
require_relative 'attribute'

module Graphiti
  class ModelConfiguration
    # contains infor about all attributes associated with single model/class
    class Attributes
      GRAPHQL_TYPE_MAPPING = {
        int: GraphQL::INT_TYPE,
        float: GraphQL::FLOAT_TYPE,
        string: GraphQL::STRING_TYPE,
        boolean: GraphQL::BOOLEAN_TYPE
      }.freeze

      def attributes
        @attributes ||= Set.new
      end

      def add(name, type = nil)
        type ||= GRAPHQL_TYPE_MAPPING[type] || type
        type ||= self.class.type_by_attribute_name(name.to_s)

        attributes.add(Attribute.new(name, type))
      end

      def each(&block)
        attributes.each(&block)
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
          raise "Please specify type for attribute #{attribute_name.inspect}. " \
                'Example `attribute #{attribute_name}, types.String`'
        end
      end
    end
  end
end
