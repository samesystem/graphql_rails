# frozen_string_literal: true

require 'graphql_rails/attributes/type_parser'
require 'graphql_rails/attributes/attribute_name_parser'

module GraphqlRails
  module Attributes
    # contains methods which are shared between various attribute-like classes
    # expects `initial_name` and `initial_type` to be defined
    module Attributable
      def field_name
        attribute_name_parser.field_name
      end

      def type_name
        @type_name ||= initial_type.to_s
      end

      def name
        attribute_name_parser.name
      end

      def required?
        attribute_name_parser.required? || !initial_type.to_s[/!$/].nil?
      end

      def graphql_model
        type_parser.graphql_model
      end

      def graphql_field_type
        @graphql_field_type ||= \
          if required?
            nullable_type.to_non_null_type
          else
            nullable_type
          end
      end

      protected

      def options
        {}
      end

      def nullable_type
        type = type_parser.graphql_type
        type.non_null? ? type.of_type : type
      end

      private

      def type_parser
        @type_parser ||= TypeParser.new(initial_type || attribute_name_parser.graphql_type)
      end

      def attribute_name_parser
        @attribute_name_parser ||= AttributeNameParser.new(initial_name, options: options)
      end
    end
  end
end
