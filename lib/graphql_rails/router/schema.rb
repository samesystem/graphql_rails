# frozen_string_literal: true

require 'graphql/pagination/active_record_relation_connection'
require 'graphql_rails/decorator/relation_decorator'
require 'graphql_rails/router/plain_cursor_encoder'

module GraphqlRails
  class Router
    # Builds GraphQL::Schema based on previously defined graphql data
    class Schema < ::GraphQL::Schema
      use GraphQL::Schema::Visibility

      connections.add(
        GraphqlRails::Decorator::RelationDecorator,
        GraphQL::Pagination::ActiveRecordRelationConnection
      )

      cursor_encoder(Router::PlainCursorEncoder)


      def self.before_type_error(&block)
        @before_type_error = block if block_given?
        @before_type_error
      end

      def self.after_type_error(&block)
        @after_type_error = block if block_given?
        @after_type_error
      end

      def self.type_error(type_error, context)
        before_type_error.call(type_error, context) if before_type_error

        return nil if type_error.is_a?(GraphQL::InvalidNullError) && context[:rendered_errors]

        super.tap do
          after_type_error.call(type_error, context) if after_type_error
        end
      end
    end
  end
end
