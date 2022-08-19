# frozen_string_literal: true

module GraphqlRails
  # Base class which is returned in case something bad happens. Contains all error rendering structure
  class SystemError < ExecutionError
    delegate :backtrace, to: :error

    def initialize(error)
      super(error.message)

      @error = error
    end

    def to_h
      super.except('locations')
    end

    def type
      'system_error'
    end

    private

    attr_reader :error
  end
end
