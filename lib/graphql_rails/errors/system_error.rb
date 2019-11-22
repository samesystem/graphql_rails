# frozen_string_literal: true

module GraphqlRails
  # base class which is returned in case something bad happens. Contains all error rendering tructure
  class SystemError < ExecutionError
    def to_h
      super.except('locations')
    end

    def type
      'system_error'
    end
  end
end
