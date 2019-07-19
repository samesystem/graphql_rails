# frozen_string_literal: true

module GraphqlRails
  module Output
    # Convers raw controller results in to graphql-friendly format
    class FormatResults
      def self.call(*args)
        new(*args).call
      end

      def initialize(original_result, input_config:, params:, graphql_context:)
        @original_result = original_result
        @input_config = input_config
        @input_params = params
        @graphql_context = graphql_context
      end

      def call
        if input_config.paginated? && original_result
          paginated_result
        else
          original_result
        end
      end

      private

      attr_reader :original_result, :input_config, :input_params, :graphql_context

      def paginated_result
        pagination_params = input_params.slice(:first, :last, :before, :after)
        pagination_options = input_config.pagination_options.merge(context: graphql_context)

        GraphQL::Relay::BaseConnection
          .connection_for_nodes(original_result)
          .new(original_result, pagination_params, pagination_options)
      end
    end
  end
end
