# frozen_string_literal: true

module GraphqlRails
  require 'graphql'

  # base class which is returned in case something bad happens. Contains all error rendering structure
  class ExecutionError < GraphQL::ExecutionError
    def to_h
      super.merge(extra_graphql_data)
    end

    def extra_graphql_data
      {}.tap do |data|
        data['type'] = type if respond_to?(:type) && type
        data['code'] = type if respond_to?(:code) && code
      end
    end
  end
end
