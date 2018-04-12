# frozen_string_literal: true

require 'graphql'

module Graphiti
  # contains info about single graphql attribute
  class Attribute
    include Comparable

    GRAPHQL_FIELD_TYPE_MAPPING = {
      int: GraphQL::INT_TYPE,
      float: GraphQL::FLOAT_TYPE,
      string: GraphQL::STRING_TYPE,
      boolean: GraphQL::BOOLEAN_TYPE
    }.freeze

    attr_reader :name, :type

    def initialize(name, type = nil)
      @name = name.to_s
      @type = type || type_by_attribute_name
    end

    def graphql_input_type

    end

    def graphql_field_type
      GRAPHQL_FIELD_TYPE_MAPPING[type.to_sym]
    end

    def <=>(other)
      if other.is_a?(self.class)
        name <=> other.name
      else
        super
      end
    end

    private

    attr_reader :type

    def type_by_attribute_name
      case name
      when 'id', /_id\Z/
        :id
      when /title\Z/, /name\Z/
        :string
      when /\?\Z/
        :boolean
      else
        raise "Please specify type for attribute #{attribute_name.inspect}. " \
              'Example `attribute #{attribute_name}, types.String`'
      end
    end
  end
end
