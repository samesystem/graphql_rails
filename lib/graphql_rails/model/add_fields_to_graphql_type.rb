# frozen_string_literal: true

module GraphqlRails
  module Model
    # Adds graphql attributes as graphql fields to given graphql schema object.
    class AddFieldsToGraphqlType
      require 'graphql_rails/concerns/service'
      require 'graphql_rails/model/call_graphql_model_method'

      include ::GraphqlRails::Service

      def initialize(klass:, attributes:)
        @klass = klass
        @attributes = attributes
      end

      def call
        attributes.each { |attribute| define_graphql_field(attribute) }
      end

      private

      attr_reader :attributes, :klass

      def define_graphql_field(attribute) # rubocop:disable Metrics/MethodLength
        klass.send(:field, *attribute.field_args, **attribute.field_options) do
          attribute.attributes.values.each do |arg_attribute|
            argument(*arg_attribute.input_argument_args, **arg_attribute.input_argument_options)
          end
        end

        klass.send(:define_method, attribute.property) do |**kwargs|
          CallGraphqlModelMethod.call(
            model: object,
            attribute_config: attribute,
            method_keyword_arguments: kwargs,
            graphql_context: context
          )
        end
      end
    end
  end
end
