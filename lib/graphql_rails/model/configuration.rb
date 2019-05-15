# frozen_string_literal: true

require 'graphql_rails/attributes'
require 'graphql_rails/model/build_graphql_type'
require 'graphql_rails/model/build_enum_type'
require 'graphql_rails/model/input'
require 'graphql_rails/model/configurable'
require 'graphql_rails/model/configuration/count_items'

module GraphqlRails
  module Model
    # stores information about model specific config, like attributes and types
    class Configuration
      include Configurable

      def initialize(model_class)
        @model_class = model_class
      end

      def attribute(attribute_name, type: nil, **attribute_options)
        attributes[attribute_name.to_s] = \
          Attributes::Attribute.new(
            attribute_name,
            type,
            attribute_options
          )
      end

      def input(input_name = nil)
        @input ||= {}
        name = input_name.to_s

        if block_given?
          @input[name] ||= Model::Input.new(model_class, input_name)
          yield(@input[name])
        end

        @input.fetch(name) do
          raise("GraphQL input with name #{input_name.inspect} is not defined for #{model_class.name}")
        end
      end

      def graphql_type
        @graphql_type ||= BuildGraphqlType.call(
          name: name, description: description, attributes: attributes
        )
      end

      def connection_type
        @connection_type ||= begin
          graphql_type.define_connection do
            field :total, types.Int, resolve: CountItems
          end
        end
      end

      private

      attr_reader :model_class

      def default_name
        @default_name ||= model_class.name.split('::').last
      end
    end
  end
end
