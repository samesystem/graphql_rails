module Graphiti
  class Router
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

      def build_type(type_name, fields)
        GraphQL::ObjectType.define do
          name type_name

          fields.each do |field_name, field_options|
            field field_name, field_options
          end
        end
      end
    end
  end
end
