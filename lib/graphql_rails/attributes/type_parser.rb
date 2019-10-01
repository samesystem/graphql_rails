# frozen_string_literal: true

require 'graphql'
require 'graphql_rails/model/build_connection_type'
require 'graphql_rails/errors/error'

module GraphqlRails
  module Attributes
    # converts string value in to GraphQL type
    class TypeParser
      require_relative './type_name_info'

      class UnknownTypeError < ArgumentError; end
      class NotSupportedFeature < GraphqlRails::Error; end

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

      RAW_GRAPHQL_TYPES = [
        GraphQL::Schema::List,
        GraphQL::BaseType,
        GraphQL::ObjectType,
        GraphQL::InputObjectType
      ].freeze

      delegate :list?, :required_inner_type?, :required_list?, :nullable_inner_name, :required?, to: :type_name_info

      def initialize(unparsed_type, paginated: false)
        @unparsed_type = unparsed_type
        @paginated = paginated
      end

      def paginated?
        @paginated
      end

      def graphql_type
        return unparsed_type if raw_graphql_type?

        if list?
          parsed_list_type
        else
          parsed_inner_type
        end
      end

      def type_arg
        if paginated?
          paginated_type_arg
        elsif list?
          list_type_arg
        else
          raw_unwrapped_type
        end
      end

      def graphql_model
        type_class = nullable_inner_name.safe_constantize

        return if type_class.nil?
        return unless type_class < GraphqlRails::Model

        type_class
      end

      protected

      def paginated_type_arg
        return graphql_model.graphql.connection_type if graphql_model

        raise NotSupportedFeature, 'pagination is only supported for models which include GraphqlRails::Model'
      end

      def list_type_arg
        if required_inner_type?
          [raw_unwrapped_type]
        else
          [raw_unwrapped_type, null: true]
        end
      end

      def parsed_type
        return unparsed_type if raw_graphql_type?

        type_by_name
      end

      def raw_unwrapped_type
        @raw_unwrapped_type ||= begin
          type = parsed_type
          type = type.of_type while wrapped_type?(type)
          type
        end
      end

      def wrapped_type?(type)
        type.is_a?(GraphQL::ListType) || type.is_a?(GraphQL::NonNullType) || type.is_a?(GraphQL::Schema::List)
      end

      def dynamicly_defined_type
        type_class = graphql_model
        return unless type_class

        type_class.graphql.graphql_type
      end

      private

      attr_reader :unparsed_type

      def parsed_list_type
        list_type = parsed_inner_type.to_list_type

        if required_list?
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

      def raw_graphql_type?
        return true if RAW_GRAPHQL_TYPES.detect { |raw_type| unparsed_type.is_a?(raw_type) }

        defined?(GraphQL::Schema::Member) &&
          unparsed_type.is_a?(Class) &&
          unparsed_type < GraphQL::Schema::Member
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

      def type_by_name
        TYPE_MAPPING.fetch(nullable_inner_name.downcase) do
          dynamicly_defined_type || raise(
            UnknownTypeError,
            "Type #{unparsed_type.inspect} is not supported. Supported scalar types are: #{TYPE_MAPPING.keys}." \
            ' All the classes that includes `GraphqlRails::Model` are also supported as types.'
          )
        end
      end
    end
  end
end
