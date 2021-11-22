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
        return @required unless @required.nil?

        (initial_type.nil? && attribute_name_parser.required?) ||
          initial_type.to_s[/!$/].present? ||
          initial_type.is_a?(GraphQL::Schema::NonNull)
      end

      def required
        @required = true
        self
      end

      def optional
        @required = false
        self
      end

      def graphql_model
        type_parser.graphql_model
      end

      def optional?
        !required?
      end

      def scalar_type?
        type_parser.raw_graphql_type? || type_parser.core_scalar_type?
      end

      private

      def type_parser
        @type_parser ||= begin
          type_for_parser = initial_type || attribute_name_parser.graphql_type
          TypeParser.new(type_for_parser, paginated: paginated?)
        end
      end

      def attribute_name_parser
        @attribute_name_parser ||= AttributeNameParser.new(initial_name, options: options)
      end
    end
  end
end
