# frozen_string_literal: true

require 'graphql'

module GraphqlRails
  module Attributes
    # converts string value in to GraphQL type
    class TypeParser
      class UnknownTypeError < ArgumentError; end

      TYPE_MAPPING = {
        'id' => GraphQL::ID_TYPE,

        'int' => GraphQL::INT_TYPE,
        'integer' => GraphQL::INT_TYPE,

        'string' => GraphQL::STRING_TYPE,
        'str' => GraphQL::STRING_TYPE,
        'text' => GraphQL::STRING_TYPE,
        'time' => GraphQL::STRING_TYPE,
        'date' => GraphQL::STRING_TYPE,

        'bool' => GraphQL::BOOLEAN_TYPE,
        'boolean' => GraphQL::BOOLEAN_TYPE,

        'float' => GraphQL::FLOAT_TYPE,
        'double' => GraphQL::FLOAT_TYPE,
        'decimal' => GraphQL::FLOAT_TYPE
      }.freeze

      def initialize(unparsed_type)
        @unparsed_type = unparsed_type
      end

      def graphql_type
        return unparsed_type if raw_graphql_type?

        if list?
          parsed_list_type
        else
          parsed_inner_type
        end
      end

      def graphql_model
        type_class = inner_type_name.safe_constantize
        return unless type_class.respond_to?(:graphql)

        type_class
      end

      private

      attr_reader :unparsed_type

      def parsed_list_type
        list_type = parsed_inner_type.to_list_type

        if required_list_type?
          list_type.to_non_null_type
        else
          list_type
        end
      end

      def parsed_inner_type
        if required_inner_type?
          type_by_name.to_non_null_type
        else
          type_by_name
        end
      end

      def required_inner_type?
        !!unparsed_type[/\w!/] # rubocop:disable Style/DoubleNegation
      end

      def list?
        unparsed_type.to_s.include?(']')
      end

      def required_list_type?
        unparsed_type.to_s.include?(']!')
      end

      def raw_graphql_type?
        unparsed_type.is_a?(GraphQL::BaseType) ||
          unparsed_type.is_a?(GraphQL::ObjectType) ||
          unparsed_type.is_a?(GraphQL::InputObjectType) ||
          (defined?(GraphQL::Schema::Member) && unparsed_type.is_a?(Class) && unparsed_type < GraphQL::Schema::Member)
      end

      def inner_type_name
        unparsed_type.to_s.tr('[]!', '')
      end

      def type_by_name
        TYPE_MAPPING.fetch(inner_type_name.downcase) do
          dynamicly_defined_type || raise(
            UnknownTypeError,
            "Type #{unparsed_type.inspect} is not supported. Supported scalar types are: #{TYPE_MAPPING.keys}." \
            ' All the classes that includes `GraphqlRails::Model` are also supported as types.'
          )
        end
      end

      def dynamicly_defined_type
        type_class = graphql_model
        return unless type_class

        type_class.graphql.graphql_type
      end
    end
  end
end
