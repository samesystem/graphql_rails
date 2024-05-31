# frozen_string_literal: true

module GraphqlRails
  module Model
    # Initializes class to define graphql type and fields.
    class FindOrBuildGraphqlTypeClass
      require 'graphql_rails/concerns/service'
      require 'graphql_rails/types/object_type'

      include ::GraphqlRails::Service

      def initialize(name:, type_name:, parent_class:, description: nil, implements: [])
        @name = name
        @type_name = type_name
        @description = description
        @new_class = false
        @parent_class = parent_class
        @implements = implements
      end

      def klass
        @klass ||= Object.const_defined?(type_name) && Object.const_get(type_name) || build_graphql_type_klass
      end

      def new_class?
        new_class
      end

      private

      attr_accessor :new_class
      attr_reader :name, :type_name, :description, :parent_class, :implements

      def build_graphql_type_klass
        graphql_type_name = name
        graphql_type_description = description
        interfaces = implements

        graphql_type_klass = Class.new(parent_class) do
          graphql_name(graphql_type_name)
          description(graphql_type_description)
          interfaces.each { |interface| implements(interface) }
        end

        self.new_class = true

        Object.const_set(type_name, graphql_type_klass)
      end
    end
  end
end
