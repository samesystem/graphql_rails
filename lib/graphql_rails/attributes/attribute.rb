# frozen_string_literal: true

require 'graphql'
require 'graphql_rails/attributes/attributable'
require 'graphql_rails/input_configurable'

module GraphqlRails
  module Attributes
    # contains info about single graphql attribute
    class Attribute
      include Attributable
      include InputConfigurable

      attr_reader :attributes

      def initialize(name, type = nil, description: nil, property: name, required: nil)
        @initial_type = type
        @initial_name = name
        @description = description
        @property = property.to_s
        @required = required
        @attributes ||= {}
      end

      def type(new_type = nil)
        return @initial_type if new_type.nil?

        @initial_type = new_type
        self
      end

      def description(new_description = nil)
        return @description if new_description.nil?

        @description = new_description
        self
      end

      def property(new_property = nil)
        return @property if new_property.nil?

        @property = new_property.to_s
        self
      end

      def field_args
        [
          field_name,
          type_parser.type_arg,
          *description,
          {
            method: property.to_sym,
            null: optional?
          }
        ]
      end

      def argument_args
        [
          field_name,
          type_parser.type_arg,
          {
            description: description,
            required: required?
          }
        ]
      end

      protected

      attr_reader :initial_type, :initial_name
    end
  end
end
