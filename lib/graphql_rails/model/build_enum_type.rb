# frozen_string_literal: true

require 'graphql'
require 'graphql_rails/attributes/attributable'

module GraphqlRails
  module Model
    # contains info about single graphql attribute
    class BuildEnumType
      class InvalidEnum < GraphqlRails::Error; end
      require 'graphql_rails/concerns/service'

      include ::GraphqlRails::Service

      def initialize(name, allowed_values:, description: nil)
        @name = name
        @allowed_values = allowed_values
        @description = description
      end

      def call
        validate
        build_enum
      end

      protected

      attr_reader :name, :allowed_values, :description

      def validate
        return if allowed_values.is_a?(Array) && !allowed_values.empty?

        validate_enum_type
        validate_enum_content
      end

      def validate_enum_type
        return if allowed_values.is_a?(Array)

        raise InvalidEnum, "Enum must be instance of Array, but instance of #{allowed_values.class} was given"
      end

      def validate_enum_content
        return unless allowed_values.empty?

        raise InvalidEnum, 'At lest one enum option must be given'
      end

      def formatted_name
        name.to_s.camelize
      end

      def build_enum(allowed_values: self.allowed_values, enum_name: formatted_name, enum_description: description)
        Class.new(GraphQL::Schema::Enum) do
          allowed_values.each do |allowed_value|
            graphql_name(enum_name)
            description(enum_description) if enum_description
            value(allowed_value.to_s.underscore.upcase, value: allowed_value)
          end

          def self.inspect
            "#{GraphQL::Schema::Enum}(#{graphql_name})"
          end
        end
      end
    end
  end
end
