# frozen_string_literal: true

require 'graphql'
require 'graphql_rails/attributes/attributable'

module GraphqlRails
  module Attributes
    # contains info about single graphql attribute
    class Attribute
      include Attributable

      attr_reader :property, :description

      def initialize(name, type = nil, description: nil, property: name)
        @initial_type = type
        @initial_name = name
        @description = description
        @property = property.to_s
      end

      def field_args
        [field_name, graphql_field_type, { property: property.to_sym, description: description }]
      end

      protected

      attr_reader :initial_type, :initial_name
    end
  end
end
