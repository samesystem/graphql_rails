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
        'id' => GraphQL::Types::ID,

        'int' => GraphQL::Types::Int,
        'integer' => GraphQL::Types::Int,

        'big_int' => GraphQL::Types::BigInt,
        'bigint' => GraphQL::Types::BigInt,

        'float' => GraphQL::Types::Float,
        'double' => GraphQL::Types::Float,
        'decimal' => GraphQL::Types::Float,

        'bool' => GraphQL::Types::Boolean,
        'boolean' => GraphQL::Types::Boolean,

        'string' => GraphQL::Types::String,
        'str' => GraphQL::Types::String,
        'text' => GraphQL::Types::String,

        'date' => GraphQL::Types::ISO8601Date,

        'time' => GraphQL::Types::ISO8601DateTime,
        'datetime' => GraphQL::Types::ISO8601DateTime,
        'date_time' => GraphQL::Types::ISO8601DateTime,

        'json' => GraphQL::Types::JSON
      }.freeze

      WRAPPER_TYPES = [
        GraphQL::Schema::List,
        GraphQL::Schema::NonNull,
        GraphQL::Language::Nodes::NonNullType,
        GraphQL::Language::Nodes::ListType
      ].freeze

      GRAPHQL_BASE_TYPES = [
        GraphQL::Schema::Object,
        GraphQL::Schema::InputObject
      ].freeze

      RAW_GRAPHQL_TYPES = (WRAPPER_TYPES + GRAPHQL_BASE_TYPES).freeze

      def unwrapped_scalar_type
        TYPE_MAPPING[nullable_inner_name.downcase]
      end

      def raw_graphql_type?
        return true if RAW_GRAPHQL_TYPES.detect { |raw_type| unparsed_type.is_a?(raw_type) }

        defined?(GraphQL::Schema::Member) &&
          unparsed_type.is_a?(Class) &&
          unparsed_type < GraphQL::Schema::Member
      end

      def core_scalar_type?
        unwrapped_scalar_type.present?
      end

      def graphql_model
        extract_type_class_if { |type| graphql_model?(type) }
      end

      def graphql_type_object
        type_object = extract_type_class_if { |type| graphql_type_object?(type) }
        type_object || graphql_model&.graphql&.graphql_type
      end

      protected

      def extract_type_class_if
        return unparsed_type if yield(unparsed_type)

        type_class = nullable_inner_name.safe_constantize
        return type_class if yield(type_class)

        nil
      end

      def graphql_model?(type_class)
        type_class.is_a?(Class) && type_class < GraphqlRails::Model
      end

      def graphql_type_object?(type_class)
        return false if !type_class.is_a?(Class) && !type_class.is_a?(Module)

        type_class < GraphQL::Schema::Member::GraphQLTypeNames
      end

      def applicable_graphql_type?(type)
        return false unless type.is_a?(Class)
        return true if type < GraphqlRails::Model

        false
      end

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
