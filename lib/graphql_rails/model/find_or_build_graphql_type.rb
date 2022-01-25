# frozen_string_literal: true

module GraphqlRails
  module Model
    # stores information about model specific config, like attributes and types
    class FindOrBuildGraphqlType
      require 'graphql_rails/concerns/service'
      require 'graphql_rails/model/find_or_build_graphql_type_class'
      require 'graphql_rails/model/add_fields_to_graphql_type'

      include ::GraphqlRails::Service

      def initialize(name:, description:, attributes:, type_name:, force_define_attributes: false)
        @name = name
        @description = description
        @attributes = attributes
        @type_name = type_name
        @force_define_attributes = force_define_attributes
      end

      def call
        klass.tap { add_fields_to_graphql_type if new_class? || force_define_attributes }
      end

      private

      attr_reader :name, :description, :attributes, :type_name, :force_define_attributes

      delegate :klass, :new_class?, to: :type_class_finder

      def type_class_finder
        @type_class_finder ||= FindOrBuildGraphqlTypeClass.new(
          name: name,
          type_name: type_name,
          description: description
        )
      end

      def add_fields_to_graphql_type
        scalar_attributes, dynamic_attributes = attributes.values.partition(&:scalar_type?)

        AddFieldsToGraphqlType.call(klass: klass, attributes: scalar_attributes)
        dynamic_attributes.each { |attribute| find_or_build_dynamic_type(attribute) }
        AddFieldsToGraphqlType.call(klass: klass, attributes: dynamic_attributes)
      end

      def find_or_build_dynamic_type(attribute)
        graphql_model = attribute.graphql_model
        find_or_build_graphql_model_type(graphql_model) if graphql_model
      end

      def find_or_build_graphql_model_type(graphql_model)
        self.class.call(
          name: graphql_model.graphql.name,
          description: graphql_model.graphql.description,
          attributes: graphql_model.graphql.attributes,
          type_name: graphql_model.graphql.type_name
        )
      end
    end
  end
end
