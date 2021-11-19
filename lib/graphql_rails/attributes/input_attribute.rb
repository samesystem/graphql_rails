# frozen_string_literal: true

module GraphqlRails
  module Attributes
    # contains info about single graphql input attribute
    class InputAttribute
      require_relative './input_type_parser'
      require_relative './attribute_name_parser'
      include Attributable
      include AttributeConfigurable

      def initialize(name)
        @initial_name = name
      end

      def input_argument_args
        type = raw_input_type || input_type_parser.input_type_arg

        [field_name, type]
      end

      def input_argument_options
        { required: required?, description: description, camelize: false }
      end

      def subtype(new_value = NOT_SET)
        return @subtype if new_value == NOT_SET

        @subtype = new_value
        self
      end

      def enum(*enum_values)
        return @enum if enum_values.empty?

        @enum = enum_values.flatten
        self
      end

      def paginated?
        false
      end

      private

      attr_reader :initial_name

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
          initial_parseable_type = type || enum_type || attribute_name_parser.graphql_type
          InputTypeParser.new(initial_parseable_type, subtype: subtype)
        end
      end

      def enum_type
        return if enum.blank?

        BuildEnumType.call(
          "#{name}_#{attribute_name}_enum",
          allowed_values: enum
        )
      end

      def raw_input_type
        return type if type.is_a?(GraphQL::InputObjectType)
        return type.graphql_input_type if type.is_a?(Model::Input)
      end
    end
  end
end
