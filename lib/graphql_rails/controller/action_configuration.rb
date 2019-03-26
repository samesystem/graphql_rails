# frozen_string_literal: true

require 'active_support/core_ext/string/filters'
require 'graphql_rails/attribute/type_parser'
require 'graphql_rails/attribute'
require 'graphql_rails/model/input_attribute'

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
        @can_return_nil = false
      end

      def permit(*no_type_attributes, **typed_attributes)
        no_type_attributes.each { |attribute| permit_attribute(attribute) }
        typed_attributes.each { |attribute, type| permit_attribute(attribute, type) }
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

      attr_reader :custom_return_type

      def build_return_type
        return nil if custom_return_type.nil?

        if paginated?
          type_parser.graphql_model ? type_parser.graphql_model.graphql.connection_type : nil
        else
          type_parser.graphql_type
        end
      end

      def type_parser
        GraphqlRails::Attribute::TypeParser.new(custom_return_type)
      end

      def permit_attribute(name, type = nil)
        field_name = name.to_s.remove(/!\Z/)
        attributes[field_name] = Model::InputAttribute.new(name.to_s, type)
      end
    end
  end
end
