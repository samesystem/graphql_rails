# frozen_string_literal: true

module GraphqlRails
  class Attribute
    # Parses attribute name and can generates graphql scalar type,
    # grapqhl name and etc. based on that
    class AttributeNameParser
      attr_reader :name

      def initialize(original_name)
        name = original_name.to_s
        @required = !name['!'].nil?
        @name = name.tr('!', '')
      end

      def field_name
        @field_name ||= begin
          field =
            if name.end_with?('?')
              "is_#{name.remove(/\?\Z/)}"
            else
              name
            end

          field.camelize(:lower)
        end
      end

      def graphql_type
        @graphql_type ||= \
          case name
          when 'id', /_id\Z/
            GraphQL::ID_TYPE
          when /\?\Z/
            GraphQL::BOOLEAN_TYPE
          else
            GraphQL::STRING_TYPE
          end
      end

      def required?
        @required
      end
    end
  end
end
