# frozen_string_literal: true

module GraphqlRails
  module Attributes
    # Contains shared parsing logic.
    # Expects that including class has:
    #  * method "unparsed_type" which might be Instance of String, Symbol, GraphQL type or so
    module TypeParseable
      require_relative './type_name_info'

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

      WRAPPER_TYPES = [
        GraphQL::Schema::List,
        GraphQL::Schema::NonNull,
        GraphQL::NonNullType,
        GraphQL::ListType
      ].freeze

      GRAPHQL_BASE_TYPES = [
        GraphQL::BaseType,
        GraphQL::ObjectType,
        GraphQL::InputObjectType
      ].freeze

      RAW_GRAPHQL_TYPES = (WRAPPER_TYPES + GRAPHQL_BASE_TYPES).freeze

      def unwrapped_scalar_type
        TYPE_MAPPING[nullable_inner_name.downcase.downcase]
      end

      def raw_graphql_type?
        return true if RAW_GRAPHQL_TYPES.detect { |raw_type| unparsed_type.is_a?(raw_type) }

        defined?(GraphQL::Schema::Member) &&
          unparsed_type.is_a?(Class) &&
          unparsed_type < GraphQL::Schema::Member
      end

      def graphql_model
        type_class = nullable_inner_name.safe_constantize

        return if type_class.nil?
        return unless type_class < GraphqlRails::Model

        type_class
      end

      protected

      def unwrap_type(type)
        unwrappable = type
        unwrappable = unwrappable.of_type while wrapped_type?(unwrappable)
        unwrappable
      end

      def wrapped_type?(type)
        WRAPPER_TYPES.any? { |wrapper| type.is_a?(wrapper) }
      end

      def nullable_inner_name
        type_name_info.nullable_inner_name
      end

      def list?
        type_name_info.list?
      end

      def required_inner_type?
        type_name_info.required_inner_type?
      end

      def required_list?
        type_name_info.required_list?
      end

      def required?
        type_name_info.required?
      end

      def type_name_info
        @type_name_info ||= begin
          type_name = \
            if unparsed_type.respond_to?(:to_type_signature)
              unparsed_type.to_type_signature
            else
              unparsed_type.to_s
            end
          TypeNameInfo.new(type_name)
        end
      end

      def raise_not_supported_type_error
        error_message = \
          "Type #{unparsed_type.inspect} is not supported. " \
          "Supported scalar types are: #{TypeParseable::TYPE_MAPPING.keys}. " \
          'All the classes that includes `GraphqlRails::Model` are also supported as types.'

        raise UnknownTypeError, error_message
      end
    end
  end
end
