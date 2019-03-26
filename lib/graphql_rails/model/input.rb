# frozen_string_literal: true

require 'graphql_rails/model/graphql_input_type_builder'
require 'graphql_rails/model/configurable'

module GraphqlRails
  module Model
    # stores information about model input specific config, like attributes and types
    class Input
      include Configurable

      def initialize(model_class, input_name_suffix)
        @model_class = model_class
        @input_name_suffix = input_name_suffix
      end

      def graphql_input_type
        @graphql_input_type ||= GraphqlInputTypeBuilder.new(
          name: name, description: description, attributes: attributes
        ).call
      end

      def attribute(attribute_name, type: nil, **attribute_options)
        attributes[attribute_name.to_s] = \
          InputAttribute.new(
            attribute_name,
            type,
            attribute_options
          )
      end

      private

      attr_reader :input_name_suffix, :model_class

      def default_name
        @default_name ||= begin
          suffix = input_name_suffix ? input_name_suffix.to_s.tableize : ''
          "#{model_class.name.split('::').last}#{suffix}Input"
        end
      end
    end
  end
end
