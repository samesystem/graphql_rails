# frozen_string_literal: true

module GraphqlRails
  class Router
    # builds GraphQL::Schema based on previously defined grahiti data
    class SchemaBuilder
      require_relative './plain_cursor_encoder'

      attr_reader :queries, :mutations, :raw_actions

      def initialize(queries:, mutations:, raw_actions:, group: nil)
        @queries = queries
        @mutations = mutations
        @raw_actions = raw_actions
        @group = group
      end

      def call
        query_type = build_group_type('Query', queries)
        mutation_type = build_group_type('Mutation', mutations)
        raw = raw_actions

        Class.new(GraphQL::Schema) do
          connections.add(
            GraphqlRails::Decorator::RelationDecorator,
            GraphQL::Pagination::ActiveRecordRelationConnection
          )
          cursor_encoder(Router::PlainCursorEncoder)
          raw.each { |action| send(action[:name], *action[:args], &action[:block]) }

          query(query_type) if query_type
          mutation(mutation_type) if mutation_type

          def self.type_from_ast(*args)
            type = super

            type.respond_to?(:to_graphql) ? type.to_graphql : type
          end
        end
      end

      private

      attr_reader :group

      def build_group_type(type_name, routes)
        group_name = group
        group_routes = routes.select { |route| route.show_in_group?(group_name) }
        return if group_routes.empty?

        build_type(type_name, group_routes)
      end

      def build_type(type_name, group_routes)
        Class.new(GraphQL::Schema::Object) do
          graphql_name(type_name)

          group_routes.each do |route|
            field(*route.name, **route.field_options)
          end

          def self.inspect
            "#{GraphQL::Schema::Object}(#{graphql_name})"
          end
        end
      end
    end
  end
end
