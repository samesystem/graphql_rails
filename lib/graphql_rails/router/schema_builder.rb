# frozen_string_literal: true

module GraphqlRails
  class Router
    # builds GraphQL::Schema based on previously defined grahiti data
    class SchemaBuilder
      require_relative './plain_cursor_encoder'
      require_relative './build_schema_action_type'

      attr_reader :queries, :mutations, :events, :raw_actions

      def initialize(queries:, mutations:, events:, raw_actions:, group: nil)
        @queries = queries
        @mutations = mutations
        @events = events
        @raw_actions = raw_actions
        @group = group
      end

      def call
        query_type = build_group_type('Query', queries)
        mutation_type = build_group_type('Mutation', mutations)
        subscription_type = build_group_type('Subscription', events)

        define_schema_class(query_type, mutation_type, subscription_type, raw_actions)
      end

      private

      attr_reader :group

      # rubocop:disable Metrics/MethodLength
      def define_schema_class(query_type, mutation_type, subscription_type, raw)
        Class.new(GraphQL::Schema) do
          use GraphQL::Schema::Visibility

          connections.add(
            GraphqlRails::Decorator::RelationDecorator,
            GraphQL::Pagination::ActiveRecordRelationConnection
          )
          cursor_encoder(Router::PlainCursorEncoder)
          raw.each { |action| send(action[:name], *action[:args], **action[:kwargs], &action[:block]) }

          query(query_type) if query_type
          mutation(mutation_type) if mutation_type
          subscription(subscription_type) if subscription_type
        end
      end
      # rubocop:enable Metrics/MethodLength

      def build_group_type(type_name, routes)
        group_name = group
        group_routes =
          routes
          .select { |route| route.show_in_group?(group_name) }
          .reverse
          .uniq(&:name)
          .reverse

        return if group_routes.empty? && type_name != 'Query'

        BuildSchemaActionType.call(type_name: type_name, routes: group_routes)
      end
    end
  end
end
