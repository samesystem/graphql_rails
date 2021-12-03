# frozen_string_literal: true

module GraphqlRails
  module Attributes
    # Parses attribute name and can generates graphql scalar type,
    # grapqhl name and etc. based on that
    class AttributeNameParser
      def initialize(original_name, options: {})
        @original_name = original_name.to_s
        @options = options
      end

      def field_name
        @field_name ||= \
          if original_format?
            preprocesed_name
          else
            preprocesed_name.camelize(:lower)
          end
      end

      def graphql_type
        @graphql_type ||= \
          case name
          when 'id', /_id\Z/
            GraphQL::Types::ID
          when /\?\Z/
            GraphQL::Types::Boolean
          else
            GraphQL::Types::String
          end
      end

      def required?
        original_name['!'].present? || original_name.end_with?('?')
      end

      def name
        @name ||= original_name.tr('!', '')
      end

      private

      attr_reader :options, :original_name

      def original_format?
        options[:input_format] == :original || options[:attribute_name_format] == :original
      end

      def preprocesed_name
        if name.end_with?('?')
          "is_#{name.remove(/\?\Z/)}"
        else
          name
        end
      end
    end
  end
end
