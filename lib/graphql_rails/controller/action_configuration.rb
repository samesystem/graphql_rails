# frozen_string_literal: true

require 'active_support/core_ext/string/filters'
require 'graphql_rails/attributes'

module GraphqlRails
  class Controller
    # stores all graphql_rails contoller specific config
    class ActionConfiguration
      attr_reader :attributes, :pagination_options

      def initialize_copy(other)
        super
        @attributes = other.instance_variable_get(:@attributes).dup.transform_values(&:dup)
      end

      def initialize
        @attributes = {}
        @action_options = {}
        @can_return_nil = false
      end

      def options(input_format:)
        @action_options[:input_format] = input_format
        self
      end

      def permit(*no_type_attributes, **typed_attributes)
        no_type_attributes.each { |attribute| permit_input(attribute) }
        typed_attributes.each { |attribute, type| permit_input(attribute, type: type) }
        self
      end

      def permit_input(name, type: nil, description: nil, subtype: nil)
        field_name = name.to_s.remove(/!\Z/)

        attributes[field_name] = Attributes::InputAttribute.new(
          name.to_s, type,
          description: description,
          subtype: subtype,
          options: action_options
        )
        self
      end

      def paginated(pagination_options = {})
        @return_type = nil
        @pagination_options = pagination_options
        permit(:before, :after, first: :int, last: :int)
      end

      def description(new_description = nil)
        if new_description
          @description = new_description
          self
        else
          @description
        end
      end

      def can_return_nil
        @can_return_nil = true
        self
      end

      def returns(custom_return_type)
        @return_type = nil
        @custom_return_type = custom_return_type
        self
      end

      def can_return_nil?
        @can_return_nil
      end

      def paginated?
        !!pagination_options # rubocop:disable Style/DoubleNegation
      end

      def return_type
        @return_type ||= build_return_type
      end

      private

      attr_reader :custom_return_type, :action_options

      def build_return_type
        return nil if custom_return_type.nil?

        if paginated?
          type_parser.graphql_model ? type_parser.graphql_model.graphql.connection_type : nil
        else
          type_parser.graphql_type
        end
      end

      def type_parser
        Attributes::TypeParser.new(custom_return_type)
      end
    end
  end
end
