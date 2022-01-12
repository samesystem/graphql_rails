# frozen_string_literal: true

require 'graphql_rails/types/argument_type'
require 'graphql_rails/types/hidable_by_group'

module GraphqlRails
  module Types
    # Base field for all GraphqlRails model fields
    class FieldType < GraphQL::Schema::Field
      include GraphqlRails::Types::HidableByGroup
      argument_class(GraphqlRails::Types::ArgumentType)
    end
  end
end
