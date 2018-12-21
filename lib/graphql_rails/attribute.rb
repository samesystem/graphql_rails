# frozen_string_literal: true

require 'graphql'
require 'graphql_rails/type_parser'

module GraphqlRails
  # contains info about single graphql attribute
  class Attribute
    attr_reader :name, :graphql_field_type, :property, :type_name, :description

    def initialize(name, type = nil, description: nil, property: name)
      @original_name = name.to_s
      @name = @original_name.tr('!', '')
      @type_name = type.to_s
      @graphql_field_type = parse_type(type || type_by_attribute_name)
      @description = description
      @property = property.to_s
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

    def field_args
      [field_name, graphql_field_type, { property: property.to_sym, description: description }]
    end

    private

    attr_reader :original_name

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
      type = TypeParser.new(type).call

      original_name['!'] ? type.to_non_null_type : type
    end
  end
end
