# frozen_string_literal: true

require 'graphql'
require 'graphql_rails/model/build_connection_type/count_items'

module GraphqlRails
  module Model
    # builds connection type from graphql type with some extra attributes
    class BuildConnectionType
      require 'graphql_rails/concerns/service'

      include ::GraphqlRails::Service

      attr_reader :initial_type

      def initialize(initial_type)
        @initial_type = initial_type
      end

      def call
        build_connection_type
      end

      private

      def build_connection_type
        edge_type = build_edge_type
        type = initial_type
        Class.new(GraphQL::Types::Relay::BaseConnection) do
          graphql_name("#{type.graphql_name}Connection")
          edge_type(edge_type)

          field :total, Integer, null: false

          def total
            CountItems.call(object)
          end
        end
      end

      def build_edge_type
        type = initial_type

        Class.new(GraphQL::Types::Relay::BaseEdge) do
          graphql_name("#{type.graphql_name}Edge")

          node_type(type)
        end
      end
    end
  end
end
