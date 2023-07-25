# frozen_string_literal: true

require 'graphql_rails/types/argument_type'

module GraphqlRails
  module Types
    # Base graphql type class for all GraphqlRails models
    class InputObjectType < GraphQL::Schema::InputObject
      argument_class(GraphqlRails::Types::ArgumentType)

      def self.inspect
        "#{GraphQL::Schema::InputObject}(#{graphql_name})"
      end
    end
  end
end
