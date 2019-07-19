# frozen_string_literal: true

module GraphqlRails
  module Model
    # stores information about model specific config, like attributes and types
    class BuildGraphqlType
      require 'graphql_rails/output/format_results'
      require 'graphql_rails/concerns/service'

      include ::GraphqlRails::Service

      PAGINATION_KEYS = %i[before after first last].freeze

      def initialize(name:, description: nil, attributes:)
        @name = name
        @attributes = attributes
        @description = description
      end

      def call
        type_name = name
        type_description = description
        type_attributes = attributes

        Class.new(GraphQL::Schema::Object) do
          graphql_name(type_name)
          description(type_description)

          type_attributes.each_value do |attribute|
            field(*attribute.field_args) do
              attribute.attributes.values.each do |arg_attribute|
                argument(*arg_attribute.input_argument_args)
              end
            end

            next if attribute.attributes.empty?

            define_method attribute.property do |**kwargs|
              method_kwargs = attribute.paginated? ? kwargs.except(*PAGINATION_KEYS) : kwargs
              result = object.send(attribute.property, **method_kwargs)

              Output::FormatResults.call(
                result,
                input_config: attribute,
                params: kwargs,
                graphql_context: context
              )
            end
          end
        end
      end

      private

      attr_reader :attributes, :name, :description
    end
  end
end
