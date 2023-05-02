# frozen_string_literal: true

require 'graphql_rails/concerns/service'
require 'graphql_rails/errors/execution_error'
require 'graphql_rails/errors/validation_error'
require 'graphql_rails/errors/custom_execution_error'

module GraphqlRails
  class Controller
    class Request
      # Converts user provided free-form errors in to meaningful graphql error classes
      class FormatErrors
        include Service

        def initialize(not_formatted_errors:)
          @not_formatted_errors = not_formatted_errors
        end

        def call
          if validation_errors?
            formatted_validation_errors
          else
            not_formatted_errors.map { |error| format_error(error) }
          end
        end

        private

        attr_reader :not_formatted_errors

        def validation_errors?
          defined?(ActiveModel) &&
            defined?(ActiveModel::Errors) &&
            not_formatted_errors.is_a?(ActiveModel::Errors)
        end

        def formatted_validation_errors
          not_formatted_errors.map do |field, message|
            ValidationError.new(message, field)
          end
        end

        def format_error(error)
          if error.is_a?(String)
            ExecutionError.new(error)
          elsif error.is_a?(GraphQL::ExecutionError)
            error
          elsif CustomExecutionError.accepts?(error)
            message = error[:message] || error['message']
            CustomExecutionError.new(message, error.except(:message, 'message'))
          elsif error.respond_to?(:message)
            ExecutionError.new(error.message)
          end
        end
      end
    end
  end
end
