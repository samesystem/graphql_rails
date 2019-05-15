# frozen_string_literal: true

module GraphqlRails
  require 'graphql'

  # base class which is returned in case something bad happens. Contains all error rendering tructure
  class ExecutionError < GraphQL::ExecutionError
    def to_h
      super.except('locations').merge('type' => type, 'http_status_code' => http_status_code)
    end

    def type
      'system_error'
    end

    def http_status_code
      500
    end
  end
end
