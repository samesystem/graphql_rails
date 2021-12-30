# frozen_string_literal: true

require 'graphql_rails/types/hidable_by_group'

module GraphqlRails
  module Types
    # Base argument type for all GraphqlRails inputs
    class ArgumentType < GraphQL::Schema::Argument
      include GraphqlRails::Types::HidableByGroup
    end
  end
end
