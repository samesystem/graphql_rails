# frozen_string_literal: true

module GraphqlRails
  module Model
    # Takes shortcuts for simple cases to minimize allocations
    class DirectFieldResolver
      class << self
        def call(model:, attribute_config:, method_keyword_arguments:, graphql_context:)
          property = attribute_config.property

          if method_keyword_arguments.empty? && !attribute_config.paginated?
            return simple_resolver(model: model, graphql_context: graphql_context, property: property)
          end

          CallGraphqlModelMethod.call(
            model: model,
            attribute_config: attribute_config,
            method_keyword_arguments: method_keyword_arguments,
            graphql_context: graphql_context
          )
        end

        def simple_resolver(model:, graphql_context:, property:)
          return model.send(property) unless model.respond_to?(:with_graphql_context)

          model.with_graphql_context(graphql_context) { model.send(property) }
        end
      end
    end
  end
end
