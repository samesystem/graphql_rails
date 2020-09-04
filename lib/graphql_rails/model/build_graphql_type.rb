# frozen_string_literal: true

module GraphqlRails
  module Model
    # stores information about model specific config, like attributes and types
    class BuildGraphqlType
      require 'graphql_rails/concerns/service'
      require 'graphql_rails/model/call_graphql_model_method'

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
            field(*attribute.field_args, **attribute.field_options) do
              attribute.attributes.values.each do |arg_attribute|
                argument(*arg_attribute.input_argument_args, **arg_attribute.input_argument_options)
              end
            end

            define_method attribute.property do |**kwargs|
              CallGraphqlModelMethod.call(
                model: object,
                attribute_config: attribute,
                method_keyword_arguments: kwargs,
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
