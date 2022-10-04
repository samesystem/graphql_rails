# frozen_string_literal: true

module GraphqlRails
  # GraphQL error that is raised when invalid data is given
  class ValidationError < ExecutionError
    BASE_FIELD_NAME = 'base'

    attr_reader :short_message, :field

    def initialize(short_message, field)
      super([humanized_field(field), short_message].compact.join(' '))
      @short_message = short_message
      @field = field
    end

    def type
      'validation_error'
    end

    def to_h
      super.merge('field' => field, 'short_message' => short_message)
    end

    private

    def humanized_field(field)
      return if field.blank?

      stringified_field = field.to_s
      return if stringified_field == BASE_FIELD_NAME

      stringified_field.humanize
    end
  end
end
