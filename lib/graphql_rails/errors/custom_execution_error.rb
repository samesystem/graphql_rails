# frozen_string_literal: true

module GraphqlRails
  # base class which is returned in case something bad happens. Contains all error rendering structure
  class CustomExecutionError < ExecutionError
    attr_reader :extra_graphql_data

    def self.accepts?(error)
      error.is_a?(Hash) &&
        (error.key?(:message) || error.key?('message'))
    end

    def initialize(message, extra_graphql_data = {})
      super(message)
      @extra_graphql_data = extra_graphql_data.stringify_keys
    end

    def to_h
      super
    end
  end
end
