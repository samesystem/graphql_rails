# frozen_string_literal: true

module GraphqlRails
  module Model
    # contains info about single graphql input attribute
    class InputAttribute
      include GraphqlRails::Attribute::Attributable

      attr_reader :description

      def initialize(name, type = nil, description: nil)
        @initial_name = name
        @initial_type = type
        @description = description
      end

      def function_argument_args
        [field_name, graphql_input_type, { description: description }]
      end

      def input_argument_args
        type = raw_input_type || model_input_type || nullable_type
        [field_name, type, { required: required?, description: description }]
      end

      def graphql_input_type
        raw_input_type || model_input_type || graphql_field_type
      end

      private

      attr_reader :initial_name, :initial_type

      def raw_input_type
        return initial_type if initial_type.is_a?(GraphQL::InputObjectType)
        return initial_type.graphql_input_type if initial_type.is_a?(Model::Input)
      end

      def model_input_type
        return unless graphql_model

        graphql_model.graphql.input.graphql_input_type
      end
    end
  end
end
