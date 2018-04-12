# frozen_string_literal: true

module Graphiti
  class Controller
    class GraphqlRequest
      attr_reader :object, :inputs, :context

      def initialize(object, params, context)
        @object = object
        @inputs = params
        @context = context
      end
    end
  end
end
