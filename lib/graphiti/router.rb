# frozen_string_literal: true

require 'active_support/core_ext/string/inflections'

require_relative 'router/schema_builder'
require_relative 'router/controller_function'

module Graphiti
  class Router
    def self.draw
      router = new
      yield(router)
      router.graphql_schema
    end

    def initialize
      @queries = {}
      @mutations = {}
    end

    def resources(name)
      name = name.to_s

      query name.singularize, to: "#{name}#show"
      query name, to: "#{name}#index"

      mutation "create_#{name}", to: "#{name}#create"
      mutation "update)#{name}", to: "#{name}#update"
      mutation "delete_#{name}", to: "#{name}#destroy"
    end

    def query(name, to:)
      queries[name.to_s.camelize(:lower)] = { function: ControllerFunction.new(to)  }
    end

    def mutation(name, to:)
      queries[name.to_s.camelize(:lower)] = { function: ControllerFunction.new(to)  }
    end

    def graphql_schema
      SchemaBuilder.new(queries: queries, mutations: mutations).call
    end

    private

    attr_reader :mutations, :queries
  end
end
