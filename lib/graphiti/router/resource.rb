# frozen_string_literal: true

module Graphiti
  class Router
    class Resource
      attr_reader :name, :router

      def initialize(resource_name, model, router)
        @router = router
        @model = model
        @resource_name = resource_name
      end

      def query(query_name)
        router.query [query_name, resource_name].join('_'), resolver: -> { model.public_send(query_name) }
      end
    end
  end
end
