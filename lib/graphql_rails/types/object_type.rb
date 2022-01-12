# frozen_string_literal: true

require 'graphql_rails/types/field_type'

module GraphqlRails
  module Types
    # Base graphql type class for all GraphqlRails models
    class ObjectType < GraphQL::Schema::Object
      field_class(GraphqlRails::Types::FieldType)
    end
  end
end
