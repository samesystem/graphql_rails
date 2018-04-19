# frozen_string_literal: true

require 'active_support/core_ext/string/inflections'

require_relative 'router/schema_builder'
require_relative 'router/controller_function'
require_relative 'router/mutation_action'
require_relative 'router/query_action'
require_relative 'router/resource_actions_builder'

module Graphiti
  # graphql router that mimics Rails.application.routes
  class Router
    def self.draw(&block)
      router = new
      router.instance_eval(&block)
      router.graphql_schema
    end

    attr_reader :actions

    def initialize
      @actions ||= Set.new
    end

    def resources(name, **options, &block)
      actions_builder = ResourceActionsBuilder.new(name, **options)
      actions_builder.instance_eval(&block) if block
      actions.merge(actions_builder.actions)
    end

    def query(name, to:)
      actions << QueryAction.new(name, to: to)
    end

    def mutation(name, to:)
      actions << MutationAction.new(name, to: to)
    end

    def graphql_schema
      SchemaBuilder.new(queries: actions.select(&:query?), mutations: actions.select(&:mutation?)).call
    end
  end
end
