# frozen_string_literal: true

require 'graphql'

module GraphqlRails
  module Attributes
    # converts string value in to GraphQL type
    class InputTypeParser
      require_relative './type_parseable'

      include TypeParseable

      def initialize(unparsed_type, subtype:)
        @unparsed_type = unparsed_type
        @subtype = subtype
      end

      def graphql_type
        return nil if unparsed_type.nil?

        partly_parsed_type || parsed_type
      end

      def nullable_type
        unwrapped_type
      end

      def input_type_arg
        if list?
          list_type_arg
        else
          unwrapped_type
        end
      end

      private

      attr_reader :unparsed_type

      def unwrapped_type
        raw_unwrapped_type || unwrapped_scalar_type || unwrapped_model_input_type || raise_not_supported_type_error
      end

      private

      attr_reader :subtype

      def raw_unwrapped_type
        unparsed_type if raw_graphql_type?
      end

      def list_type_arg
        if required_inner_type?
          [unwrapped_type]
        else
          [unwrapped_type, null: true]
        end
      end

      def unwrapped_model_input_type
        type_class = graphql_model
        return unless type_class

        type_class.graphql.input(subtype).graphql_input_type
      end
    end
  end
end
