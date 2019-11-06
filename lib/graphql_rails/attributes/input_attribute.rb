# frozen_string_literal: true

module GraphqlRails
  module Attributes
    # contains info about single graphql input attribute
    class InputAttribute
      require_relative './input_type_parser'
      require_relative './attribute_name_parser'
      include Attributable

      attr_reader :description

      # rubocop:disable Metrics/ParameterLists
      def initialize(name, type = nil, description: nil, subtype: nil, required: nil, options: {})
        @initial_name = name
        @initial_type = type
        @description = description
        @options = options
        @subtype = subtype
        @required = required
      end
      # rubocop:enable Metrics/ParameterLists

      def input_argument_args
        type = raw_input_type || input_type_parser.input_type_arg

        [field_name, type, { required: required?, description: description, camelize: false }]
      end

      def paginated?
        false
      end

      private

      attr_reader :initial_name, :initial_type, :options, :subtype

      def attribute_name_parser
        @attribute_name_parser ||= AttributeNameParser.new(
          initial_name, options: attribute_naming_options
        )
      end

      def attribute_naming_options
        options.slice(:input_format)
      end

      def input_type_parser
        @input_type_parser ||= begin
          initial_parseable_type = initial_type || attribute_name_parser.graphql_type
          InputTypeParser.new(initial_parseable_type, subtype: subtype)
        end
      end

      def raw_input_type
        return initial_type if initial_type.is_a?(GraphQL::InputObjectType)
        return initial_type.graphql_input_type if initial_type.is_a?(Model::Input)
      end
    end
  end
end
