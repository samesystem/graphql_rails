# frozen_string_literal: true

module GraphqlRails
  # Base class which is returned in case something bad happens. Contains all error rendering structure
  class SystemError < ExecutionError
    delegate :backtrace, to: :original_error

    attr_reader :original_error

    def initialize(original_error)
      super(original_error.message)

      @original_error = original_error
    end

    def to_h
      super.except('locations')
    end

    def type
      'system_error'
    end
  end
end
