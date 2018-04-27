# frozen_string_literal: true

require_relative '../errors/execution_error'

module GraphqlRails
  class Controller
    # Contains all info related with single request to controller
    class Request
      attr_accessor :object_to_return
      attr_reader :errors

      def initialize(graphql_object, inputs, context)
        @graphql_object = graphql_object
        @inputs = inputs
        @context = context
      end

      def errors=(new_errors)
        @errors = new_errors

        new_errors.each do |error|
          error_message = error.is_a?(String) ? error : error.message
          context.add_error(ExecutionError.new(error_message))
        end
      end

      def no_object_to_return?
        !defined?(@object_to_return)
      end

      def params
        inputs.to_h
      end

      private

      attr_reader :graphql_object, :inputs, :context
    end
  end
end
