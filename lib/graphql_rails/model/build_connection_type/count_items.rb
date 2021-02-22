# frozen_string_literal: true

module GraphqlRails
  module Model
    class BuildConnectionType
      # Used when generating ConnectionType.
      # It handles all the logic which is related with counting total items
      class CountItems
        require 'graphql_rails/concerns/service'

        include ::GraphqlRails::Service

        def initialize(graphql_object)
          @graphql_object = graphql_object
        end

        def call
          if active_record?
            list.except(:offset).size
          else
            list.size
          end
        end

        private

        attr_reader :graphql_object

        def list
          graphql_object.items
        end

        def active_record?
          defined?(ActiveRecord) && list.is_a?(ActiveRecord::Relation)
        end
      end
    end
  end
end
