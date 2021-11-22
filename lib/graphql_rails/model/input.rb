# frozen_string_literal: true

module GraphqlRails
  module Model
    # stores information about model input specific config, like attributes and types
    class Input
      require 'graphql_rails/concerns/chainable_options'
      require 'graphql_rails/model/configurable'
      require 'graphql_rails/model/build_graphql_input_type'

      include Configurable

      chainable_option :enum

      def initialize(model_class, input_name_suffix)
        @model_class = model_class
        @input_name_suffix = input_name_suffix
      end

      def graphql_input_type
        @graphql_input_type ||= BuildGraphqlInputType.call(
          name: name, description: description, attributes: attributes
        )
      end

      def attribute(attribute_name, type: nil, enum: nil, **attribute_options)
        input_type = attribute_type(attribute_name, type: type, enum: enum, **attribute_options)

        attributes[attribute_name.to_s] = \
          Attributes::InputAttribute.new(attribute_name).with(type: input_type, **attribute_options)
      end

      def enum(*enum_values)
        values = enum_values.flatten

        enum_type = BuildEnumType.call(
          "#{name}_#{attribute_name}_enum",
          allowed_values: values,
          description: description
        )
        type(enum_type)
      end

      private

      attr_reader :input_name_suffix, :model_class

      def build_attribute(attribute_name)
        Attributes::InputAttribute.new(attribute_name)
      end

      def default_name
        @default_name ||= begin
          suffix = input_name_suffix ? input_name_suffix.to_s.camelize : ''
          "#{model_class.name.split('::').last}#{suffix}Input"
        end
      end

      def attribute_type(attribute_name, type:, enum:, description: nil, **_other)
        return type unless enum

        BuildEnumType.call(
          "#{name}_#{attribute_name}_enum",
          allowed_values: enum,
          description: description
        )
      end
    end
  end
end
