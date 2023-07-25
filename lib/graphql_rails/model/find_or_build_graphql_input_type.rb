# frozen_string_literal: true

require 'graphql_rails/types/input_object_type'
require 'graphql_rails/concerns/service'
require 'graphql_rails/model/find_or_build_graphql_type'

module GraphqlRails
  module Model
    # stores information about model specific config, like attributes and types
    class FindOrBuildGraphqlInputType < FindOrBuildGraphqlType
      include ::GraphqlRails::Service

      private

      def parent_class
        GraphqlRails::Types::InputObjectType
      end

      def add_attributes_batch(attributes)
        klass.class_eval do
          attributes.each do |attribute|
            argument(*attribute.input_argument_args, **attribute.input_argument_options)
          end
        end
      end
    end
  end
end
