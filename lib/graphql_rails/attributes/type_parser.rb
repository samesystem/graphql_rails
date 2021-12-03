# frozen_string_literal: true

require 'graphql'
require 'graphql_rails/model/build_connection_type'
require 'graphql_rails/errors/error'

module GraphqlRails
  module Attributes
    # converts string value in to GraphQL type
    class TypeParser
      require_relative './type_name_info'
      require_relative './type_parseable'

      class NotSupportedFeature < GraphqlRails::Error; end

      include TypeParseable

      delegate :list?, :required_inner_type?, :required_list?, :required?, to: :type_name_info

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

      protected

      def paginated_type_arg
        return graphql_model.graphql.connection_type if graphql_model

        error_message = "Unable to paginate #{unparsed_type.inspect}. " \
                        'Pagination is only supported for models which include GraphqlRails::Model'
        raise NotSupportedFeature, error_message
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
        @raw_unwrapped_type ||= unwrap_type(parsed_type)
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
        unwrapped_scalar_type || graphql_type_object || raise_not_supported_type_error
      end
    end
  end
end
