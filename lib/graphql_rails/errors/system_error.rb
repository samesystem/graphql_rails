# frozen_string_literal: true

module GraphqlRails
  # base class which is returned in case something bad happens. Contains all error rendering tructure
  class SystemError < ExecutionError
    attr_reader :error

    def initialize(error)
      super(error.message)

      @error = error
    end

    def backtrace
      error.backtrace
    end

    def to_h
      super.except('locations')
    end

    def type
      'system_error'
    end
  end
end
