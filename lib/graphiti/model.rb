# frozen_string_literal: true

require_relative 'model_configuration'

module Graphiti
  module Model
    def self.included(base)
      base.extend(ClassMethods)
    end

    module ClassMethods
      def graphiti
        @graphiti ||= ModelConfiguration.new
        yield(@graphiti) if block_given?
        @graphiti
      end

      def graphql_type
        model_name = name.split('::').last
        attributes = graphiti.attributes

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
