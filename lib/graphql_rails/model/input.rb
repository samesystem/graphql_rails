# frozen_string_literal: true

module GraphqlRails
  module Model
    # stores information about model input specific config, like attributes and types
    class Input
      require 'graphql_rails/concerns/chainable_options'
      require 'graphql_rails/model/configurable'
      require 'graphql_rails/model/find_or_build_graphql_input_type'

      include Configurable

      chainable_option :enum

      def initialize(model_class, input_name_suffix)
        @model_class = model_class
        @input_name_suffix = input_name_suffix
      end

      def graphql_input_type
        @graphql_input_type ||= FindOrBuildGraphqlInputType.call(
          name: name, description: description, attributes: attributes, type_name: type_name
        )
      end

      private

      attr_reader :input_name_suffix, :model_class

      def build_attribute(attribute_name)
        Attributes::InputAttribute.new(attribute_name, config: self)
      end

      def default_name
        @default_name ||= begin
          suffix = input_name_suffix ? input_name_suffix.to_s.camelize : ''
          "#{model_class.name.split('::').last}#{suffix}Input"
        end
      end
    end
  end
end
