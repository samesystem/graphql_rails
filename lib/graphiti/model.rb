require_relative 'graphql_attributes'

module Graphiti
  module Model
    def self.included(base)
      base.extend(ClassMethods)
    end

    module ClassMethods
      def attribute(attribute_name, type = nil)
        graphql_attributes.add(attribute_name, type)
      end

      def graphql_attributes
        @graphql_attributes ||= GraphqlAttributes.new
      end

      def graphql_type
        model_name = name.split('::').last
        attributes = graphql_attributes.attributes

        GraphQL::ObjectType.define do
          name(model_name)
          description("Generated programmatically from model: #{model_name}")

          attributes.each do |attribute|
            field(attribute.name, attribute.type)
          end
        end
      end
    end
  end
end
