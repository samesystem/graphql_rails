# frozen_string_literal: true

module GraphqlRails
  class Router
    # builds GraphQL::Schema based on previously defined grahiti data
    class SchemaBuilder
      attr_reader :queries, :mutations, :raw_actions

      def initialize(queries:, mutations:, raw_actions:)
        @queries = queries
        @mutations = mutations
        @raw_actions = raw_actions
      end

      def call
        query_type = build_type('Query', queries)
        mutation_type = build_type('Mutation', mutations)
        raw = raw_actions

        GraphQL::Schema.define do
          raw.each { |action| send(action[:name], *action[:args], &action[:block]) }

          query(query_type)
          mutation(mutation_type)
        end
      end

      private

      def build_type(type_name, routes)
        GraphQL::ObjectType.define do
          name type_name

          routes.each do |route|
            field route.name, function: Controller::ControllerFunction.from_route(route)
          end
        end
      end
    end
  end
end
