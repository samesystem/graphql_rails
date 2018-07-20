# frozen_string_literal: true

require 'graphql_rails/attribute'
require 'graphql_rails/model/graphql_type_builder'

module GraphqlRails
  module Model
    # stores information about model specific config, like attributes and types
    class Configuration
      attr_reader :attributes

      def initialize(model_class)
        @model_class = model_class
        @attributes = {}
      end

      def name(type_name = nil)
        @name = type_name if type_name
        @name || name_by_class_name
      end

      def description(new_description = nil)
        @description = new_description if new_description
        @description
      end

      def attribute(attribute_name, type: nil, **attribute_options)
        attributes[attribute_name.to_s] = \
          Attribute.new(
            attribute_name,
            type,
            attribute_options
          )
      end

      def graphql_type
        @graphql_type ||= GrapqhlTypeBuilder.new(
          name: name, description: description, attributes: attributes
        ).call
      end

      def connection_type
        @connection_type ||= begin
          graphql_type.define_connection do
            field :total, types.Int, resolve: ->(obj, _args, _ctx) { obj.nodes.size }
          end
        end
      end

      private

      attr_reader :model_class

      def name_by_class_name
        @name_by_class_name ||= model_class.name.split('::').last
      end
    end
  end
end
