# frozen_string_literal: true

require 'graphql'
require 'graphql_rails/attributes/attributable'

module GraphqlRails
  module Model
    # contains info about single graphql attribute
    class BuildEnumType
      def self.call(*args)
        new(*args).call
      end

      def initialize(name, allowed_values:, description: nil)
        @name = name
        @allowed_values = allowed_values
        @description = description
      end

      def call
        allowed_values = self.allowed_values
        enum_name = name.to_s.camelize
        enum_description = description

        Class.new(GraphQL::Schema::Enum) do
          allowed_values.each do |allowed_value|
            graphql_name(enum_name)
            description(enum_description) if enum_description
            value(allowed_value.to_s.underscore.upcase, value: allowed_value)
          end
        end
      end

      protected

      attr_reader :name, :allowed_values, :description
    end
  end
end
