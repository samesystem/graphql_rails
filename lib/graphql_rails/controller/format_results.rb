# frozen_string_literal: true

module GraphqlRails
  class Controller
    # Convers raw controller results in to graphql-friendly format
    class FormatResults
      def initialize(original_result, action_config:, params:, graphql_context:)
        @original_result = original_result
        @action_config = action_config
        @controller_params = params
        @graphql_context = graphql_context
      end

      def call
        if action_config.paginated? && original_result
          paginated_result
        else
          original_result
        end
      end

      private

      attr_reader :original_result, :action_config, :controller_params, :graphql_context

      def paginated_result
        pagination_params = controller_params.slice(:first, :last, :before, :after)
        pagination_options = action_config.pagination_options.merge(context: graphql_context)

        GraphQL::Relay::BaseConnection
          .connection_for_nodes(original_result)
          .new(original_result, pagination_params, pagination_options)
      end
    end
  end
end
