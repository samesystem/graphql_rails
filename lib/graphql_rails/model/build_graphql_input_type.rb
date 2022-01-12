# frozen_string_literal: true

require 'graphql_rails/types/argument_type'
require 'graphql_rails/concerns/service'

module GraphqlRails
  module Model
    # stores information about model specific config, like attributes and types
    class BuildGraphqlInputType
      include ::GraphqlRails::Service

      def initialize(name:, description: nil, attributes:)
        @name = name
        @attributes = attributes
        @description = description
      end

      def call
        type_name = name
        type_description = description
        type_attributes = attributes

        Class.new(GraphQL::Schema::InputObject) do
          argument_class(GraphqlRails::Types::ArgumentType)
          graphql_name(type_name)
          description(type_description)

          type_attributes.each_value do |type_attribute|
            argument(*type_attribute.input_argument_args, **type_attribute.input_argument_options)
          end

          def self.inspect
            "#{GraphQL::Schema::InputObject}(#{graphql_name})"
          end
        end
      end

      private

      attr_reader :model_configuration, :attributes, :name, :description
    end
  end
end
