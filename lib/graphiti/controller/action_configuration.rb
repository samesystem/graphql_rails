# frozen_string_literal: true

require 'active_support/core_ext/string/filters'
require 'graphiti/attribute'

module Graphiti
  class Controller
    # stores all graphiti contoller specific config
    class ActionConfiguration
      attr_reader :attributes, :return_type

      def initialize
        @attributes = {}
        @can_return_nil = false
      end

      def permit(*no_type_attributes, **typed_attributes)
        no_type_attributes.each { |attribute| permit_attribute(attribute) }
        typed_attributes.each { |attribute, type| permit_attribute(attribute, type) }
        self
      end

      def can_return_nil
        @can_return_nil = true
        self
      end

      def returns(new_return_type)
        @return_type = new_return_type
        self
      end

      def can_return_nil?
        @can_return_nil
      end

      private

      def permit_attribute(name, type = nil)
        field_name = name.to_s.remove(/!\Z/)
        required = name.to_s.end_with?('!')
        attributes[field_name] = Attribute.new(field_name, type, required: required)
      end
    end
  end
end
