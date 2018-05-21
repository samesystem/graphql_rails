# frozen_string_literal: true

require 'graphql'

module GraphqlRails
  class Attribute
    # converts string value in to GraphQL type
    class AttributeTypeParser
      class UnknownTypeError < ArgumentError; end

      TYPE_MAPPING = {
        'id' => GraphQL::ID_TYPE,

        'int' => GraphQL::INT_TYPE,
        'integer' => GraphQL::INT_TYPE,

        'string' => GraphQL::STRING_TYPE,
        'str' => GraphQL::STRING_TYPE,
        'text' => GraphQL::STRING_TYPE,
        'time' => GraphQL::STRING_TYPE,
        'date' =>  GraphQL::STRING_TYPE,

        'bool' => GraphQL::BOOLEAN_TYPE,
        'boolean' => GraphQL::BOOLEAN_TYPE,

        'float' => GraphQL::FLOAT_TYPE,
        'double' => GraphQL::FLOAT_TYPE,
        'decimal' => GraphQL::FLOAT_TYPE
      }.freeze

      def initialize(unparsed_type)
        @unparsed_type = unparsed_type
      end

      def call
        return unparsed_type if raw_graphql_type?

        if list?
          parsed_list_type
        else
          parsed_inner_type
        end
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
          (defined?(GraphQL::Schema::Member) && unparsed_type.is_a?(Class) && unparsed_type < GraphQL::Schema::Member)
      end

      def inner_type_name
        unparsed_type.to_s.downcase.tr('[]!', '')
      end

      def type_by_name
        TYPE_MAPPING.fetch(inner_type_name) do
          raise(
            UnknownTypeError,
            "Type #{unparsed_type.inspect} is not supported. Supported types are: #{TYPE_MAPPING.keys}"
          )
        end
      end
    end
  end
end
