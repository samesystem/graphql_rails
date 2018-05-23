# frozen_string_literal: true

require 'graphql'
require 'graphql_rails/attribute/attribute_type_parser'

module GraphqlRails
  # contains info about single graphql attribute
  class Attribute
    attr_reader :name, :graphql_field_type, :property, :type_name

    def initialize(name, type = nil, hidden: false, property: name)
      @name = name.to_s
      @type_name = type.to_s
      @graphql_field_type = parse_type(type || type_by_attribute_name)
      @hidden = hidden
      @property = property.to_s
    end

    def hidden?
      @hidden
    end

    def field_name
      field =
        if name.end_with?('?')
          "is_#{name.remove(/\?\Z/)}"
        else
          name
        end

      field.camelize(:lower)
    end

    private

    def type_by_attribute_name
      case name
      when 'id', /_id\Z/
        GraphQL::ID_TYPE
      when /\?\Z/
        GraphQL::BOOLEAN_TYPE
      else
        GraphQL::STRING_TYPE
      end
    end

    def parse_type(type)
      AttributeTypeParser.new(type).call
    end
  end
end
