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
        @name ||= type_name
      end

      def description(description = nil)
        @description ||= description
      end

      def attribute(attribute_name, type: nil, hidden: false, property: attribute_name)
        attributes[attribute_name.to_s] = Attribute.new(attribute_name, type, hidden: hidden, property: property)
      end

      def graphql_type
        @graphql_type ||= begin
         type_name = name || name_by_class_name
         GrapqhlTypeBuilder.new(name: type_name, description: description, attributes: attributes).call
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
