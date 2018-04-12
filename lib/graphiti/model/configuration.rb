# frozen_string_literal: true

require 'graphiti/attribute'

module Graphiti
  module Model
    class Configuration
      attr_reader :attributes

      def initialize(model_class)
        @model_class = model_class
        @attributes = {}
      end

      def attribute(attribute_name, type = nil)
        attributes[attribute_name.to_s] = Attribute.new(attribute_name, type)
      end

      def graphql_type
        @graphql_type ||= generate_graphql_type(graphql_type_name, attributes)
      end

      private

      attr_reader :model_class

      def graphql_type_name
        model_class.name.split('::').last
      end

      def generate_graphql_type(type_name, attributes)
        GraphQL::ObjectType.define do
          name(type_name)
          description("Generated programmatically from model: #{type_name}")

          attributes.each_value do |attribute|
            field(attribute.name, attribute.graphql_field_type)
          end
        end
      end
    end
  end
end
