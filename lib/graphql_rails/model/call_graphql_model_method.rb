# frozen_string_literal: true

module GraphqlRails
  module Model
    # Executes model method and adds additional meta data if needed
    class CallGraphqlModelMethod
      require 'graphql_rails/concerns/service'

      include ::GraphqlRails::Service

      PAGINATION_KEYS = %i[before after first last].freeze

      @instance_cache = {}

      class << self
        attr_reader :instance_cache

        def call(*_args, **kwargs)
          cache_key = kwargs[:attribute_config].object_id
          @instance_cache[cache_key] ||= new
          @instance_cache[cache_key].call_with_args(**kwargs)
        end
      end

      def call_with_args(model:, method_keyword_arguments:, graphql_context:, attribute_config:)
        @model = model
        @method_keyword_arguments = method_keyword_arguments
        @graphql_context = graphql_context
        @attribute_config = attribute_config

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
          formatted_arguments = formatted_method_input(custom_keyword_arguments)
          model.send(method_name, **formatted_arguments)
        end
      end

      def formatted_method_input(keyword_arguments)
        keyword_arguments.transform_values do |input_argument|
          formatted_method_input_argument(input_argument)
        end
      end

      def formatted_method_input_argument(argument)
        return argument.to_h if argument.is_a?(GraphQL::Schema::InputObject)

        argument
      end

      def method_name
        attribute_config.property
      end

      def paginated?
        attribute_config.paginated?
      end

      def custom_keyword_arguments
        return method_keyword_arguments unless paginated?

        method_keyword_arguments.each_with_object({}) do |(key, value), result|
          result[key] = value unless PAGINATION_KEYS.include?(key)
        end
      end

      def with_graphql_context
        return yield unless model.respond_to?(:with_graphql_context)

        model.with_graphql_context(graphql_context) { yield }
      end
    end
  end
end
