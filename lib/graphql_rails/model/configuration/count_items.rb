# frozen_string_literal: true

module GraphqlRails
  module Model
    class Configuration
      # Used when generating ConnectionType.
      # It handles all the logic which is related with counting total items
      class CountItems
        def self.call(*args)
          new(*args).call
        end

        def initialize(graphql_object, _args, _ctx)
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
          graphql_object.nodes
        end

        def active_record?
          defined?(ActiveRecord) && list.is_a?(ActiveRecord::Relation)
        end
      end
    end
  end
end
