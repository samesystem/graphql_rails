# frozen_string_literal: true

module GraphqlRails
  module Attributes
    # Parses attribute name and can generates graphql scalar type,
    # grapqhl name and etc. based on that
    class AttributeNameParser
      attr_reader :name

      def initialize(original_name, options: {})
        name = original_name.to_s
        @required = !name['!'].nil?
        @name = name.tr('!', '')
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
        @required
      end

      private

      attr_reader :options

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
