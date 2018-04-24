# frozen_string_literal: true

require 'graphql'

module Graphiti
  # contains info about single graphql attribute
  class Attribute
    attr_reader :name, :type

    def initialize(name, type = nil, required: false, hidden: false)
      @name = name.to_s
      @type = parse_type(type || type_by_attribute_name)
      @required = required
      @hidden = hidden
    end

    def graphql_field_type
      @graphql_field_type ||= required? ? type.to_non_null_type : type
    end

    def required?
      @required
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
      if graphql_type?(type)
        type
      elsif type.is_a?(String) || type.is_a?(Symbol)
        map_type_name_to_type(type.to_s.downcase)
      else
        raise "Unsupported type #{type.inspect} (class: #{type.class})"
      end
    end

    def graphql_type?(type)
      type.is_a?(GraphQL::BaseType) ||
        type.is_a?(GraphQL::ObjectType) ||
        (defined?(GraphQL::Schema::Member) && type.is_a?(Class) && type < GraphQL::Schema::Member)
    end

    def map_type_name_to_type(type_name)
      case type_name
      when 'id'
        GraphQL::ID_TYPE
      when 'int', 'integer'
        GraphQL::INT_TYPE
      when 'string', 'str', 'text', 'time', 'date'
        GraphQL::STRING_TYPE
      when 'bool', 'boolean', 'mongoid::boolean'
        GraphQL::BOOLEAN_TYPE
      when 'float', 'double', 'decimal'
        GraphQL::FLOAT_TYPE
      else
        raise "Don't know how to parse type with name #{type_name.inspect}"
      end
    end
  end
end
