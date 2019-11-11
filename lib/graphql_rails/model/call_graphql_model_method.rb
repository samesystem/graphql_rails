# frozen_string_literal: true

module GraphqlRails
  module Model
    # Executes model method and adds additional meta data if needed
    class CallGraphqlModelMethod
      require 'graphql_rails/concerns/service'

      include ::GraphqlRails::Service

      PAGINATION_KEYS = %i[before after first last].freeze

      def initialize(model:, method_keyword_arguments:, graphql_context:, attribute_config:)
        @model = model
        @method_keyword_arguments = method_keyword_arguments
        @graphql_context = graphql_context
        @attribute_config = attribute_config
      end

      def call
        with_graphql_context do
          run_method
        end
      end

      private

      attr_reader :model, :attribute_config, :graphql_context, :method_keyword_arguments

      def run_method
        if custom_keyword_arguments.empty?
          model.send(method_name)
        else
          model.send(method_name, **custom_keyword_arguments)
        end
      end

      def method_name
        attribute_config.property
      end

      def paginated?
        attribute_config.paginated?
      end

      def custom_keyword_arguments
        return method_keyword_arguments unless paginated?

        method_keyword_arguments.except(*PAGINATION_KEYS)
      end

      def with_graphql_context
        return yield unless model.respond_to?(:with_graphql_context)

        model.with_graphql_context(graphql_context) { yield }
      end
    end
  end
end
