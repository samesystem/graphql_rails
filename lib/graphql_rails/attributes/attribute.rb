# frozen_string_literal: true

require 'graphql'
require 'graphql_rails/attributes/attributable'
require 'graphql_rails/attributes/attribute_configurable'
require 'graphql_rails/input_configurable'

module GraphqlRails
  module Attributes
    # contains info about single graphql attribute
    class Attribute
      include Attributable
      include AttributeConfigurable
      include InputConfigurable

      attr_reader :attributes

      def initialize(name)
        @initial_name = name
        @property = name.to_s
        @attributes ||= {}
      end

      def property(new_value = NOT_SET)
        return @property if new_value == NOT_SET

        @property = new_value.to_s
        self
      end

      def field_args
        [
          field_name,
          type_parser.type_arg,
          description
        ].compact
      end

      def field_options
        {
          method: property.to_sym,
          null: optional?,
          camelize: camelize?,
          groups: groups,
          **deprecation_reason_params
        }
      end

      protected

      attr_reader :initial_name

      private

      def camelize?
        options[:input_format] != :original && options[:attribute_name_format] != :original
      end

      def deprecation_reason_params
        { deprecation_reason: deprecation_reason }.compact
      end
    end
  end
end
