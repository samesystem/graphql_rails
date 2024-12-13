# frozen_string_literal: true

module GraphqlRails
  class Controller
    # Contains all info related with single request to controller
    class Request
      require 'graphql_rails/controller/request/format_errors'

      attr_accessor :object_to_return
      attr_reader :errors, :context, :lookahead

      def initialize(graphql_object, inputs, context)
        @graphql_object = graphql_object
        @inputs = inputs.except(:lookahead)
        @lookahead = inputs[:lookahead]
        @context = context
        @errors = []
      end

      def errors=(new_errors)
        @errors = FormatErrors.call(not_formatted_errors: new_errors)

        @errors.each { |error| context.add_error(error) }
      end

      def no_object_to_return?
        !defined?(@object_to_return)
      end

      def params
        deep_transform_values(inputs.to_h) do |val|
          graphql_object_to_hash(val)
        end
      end

      private

      attr_reader :graphql_object, :inputs

      def graphql_object_to_hash(object)
        if object.is_a?(GraphQL::Dig)
          object.to_h
        elsif object.is_a?(Array)
          object.map { |item| graphql_object_to_hash(item) }
        else
          object
        end
      end

      def deep_transform_values(hash, &block)
        return hash unless hash.is_a?(Hash)

        hash.transform_values do |val|
          if val.is_a?(Hash)
            deep_transform_values(val, &block)
          else
            yield(val)
          end
        end
      end
    end
  end
end
