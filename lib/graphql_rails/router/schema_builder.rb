# frozen_string_literal: true

module GraphqlRails
  class Router
    # builds GraphQL::Schema based on previously defined grahiti data
    class SchemaBuilder
      attr_reader :queries, :mutations

      def initialize(queries:, mutations:)
        @queries = queries
        @mutations = mutations
      end

      def call
        query_type = build_type('Query', queries)
        mutation_type = build_type('Mutation', mutations)

        GraphQL::Schema.define do
          query(query_type)
          mutation(mutation_type)
        end
      end

      private

      def build_type(type_name, routes)
        GraphQL::ObjectType.define do
          name type_name

          routes.each do |route|
            field route.name, Controller::ControllerFunction.from_route(route)
          end
        end
      end
    end
  end
end
