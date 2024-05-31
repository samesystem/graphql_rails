# frozen_string_literal: true

require 'graphql_rails/attributes'
require 'graphql_rails/model/find_or_build_graphql_type'
require 'graphql_rails/model/input'
require 'graphql_rails/model/configurable'
require 'graphql_rails/model/build_connection_type'

module GraphqlRails
  module Model
    # stores information about model specific config, like attributes and types
    class Configuration
      include ChainableOptions
      include Configurable

      def initialize(model_class)
        @model_class = model_class
      end

      def initialize_copy(other)
        super
        @connection_type = nil
        @graphql_type = nil
        @input = other.instance_variable_get(:@input)&.transform_values(&:dup)
      end

      def implements(*interfaces)
        previous_implements = get_or_set_chainable_option(:implements) || []
        return previous_implements if interfaces.blank?

        full_implements = (previous_implements + interfaces).uniq

        get_or_set_chainable_option(:implements, full_implements) || []
      end

      def attribute(attribute_name, **attribute_options)
        key = attribute_name.to_s

        attributes[key] ||= build_attribute(attribute_name)

        attributes[key].tap do |new_attribute|
          new_attribute.with(**attribute_options)
          yield(new_attribute) if block_given?
        end
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
        @graphql_type ||= FindOrBuildGraphqlType.call(
          name: name,
          description: description,
          attributes: attributes,
          type_name: type_name,
          implements: implements
        )
      end

      def connection_type
        @connection_type ||= BuildConnectionType.call(graphql_type)
      end

      def with_ensured_fields!
        return self if @graphql_type.blank?

        reset_graphql_type if attributes.any? && graphql_type.fields.length != attributes.length

        self
      end

      private

      attr_reader :model_class

      def build_attribute(attribute_name)
        Attributes::Attribute.new(attribute_name)
      end

      def default_name
        @default_name ||= model_class.name.split('::').last
      end

      def reset_graphql_type
        @graphql_type = FindOrBuildGraphqlType.call(
          name: name,
          description: description,
          attributes: attributes,
          type_name: type_name,
          implements: implements,
          force_define_attributes: true
        )
      end
    end
  end
end
