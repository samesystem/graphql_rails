# frozen_string_literal: true

require 'graphql'

module GraphqlRails
  module Attributes
    # converts string value in to GraphQL type
    class InputTypeParser < TypeParser
      def initialize(unparsed_type, subtype:)
        super(unparsed_type)
        @subtype = subtype
      end

      def graphql_type
        return nil if unparsed_type.nil?

        partly_parsed_type || parsed_type
      end

      def nullable_type
        return nil if unparsed_type.nil?

        partly_parsed_type || parsed_nullable_type
      end

      protected

      def partly_parsed_type
        return unparsed_type if raw_graphql_type?
        return unparsed_type.graphql_input_type if unparsed_type.is_a?(GraphqlRails::Model::Input)
      end

      def parsed_nullable_type
        if list?
          parsed_inner_type.to_list_type
        else
          type_by_name
        end
      end

      def parsed_type
        if list?
          parsed_list_type
        else
          parsed_inner_type
        end
      end

      def raw_graphql_type?
        unparsed_type.is_a?(GraphQL::InputObjectType) || super
      end

      def dynamicly_defined_type
        type_class = graphql_model
        return unless type_class

        type_class.graphql.input(*subtype).graphql_input_type
      end

      def parsed_list_type
        list_type = parsed_inner_type.to_list_type

        if required_list?
          list_type = list_type.to_graphql if list_type.respond_to?(:to_graphql)
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

      private

      attr_reader :subtype
    end
  end
end
