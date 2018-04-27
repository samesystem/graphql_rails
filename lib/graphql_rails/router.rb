# frozen_string_literal: true

require 'active_support/core_ext/string/inflections'

require_relative 'router/schema_builder'
require_relative 'router/mutation_action'
require_relative 'router/query_action'
require_relative 'router/resource_actions_builder'

module GraphqlRails
  # graphql router that mimics Rails.application.routes
  class Router
    def self.draw(&block)
      router = new
      router.instance_eval(&block)
      router.graphql_schema
    end

    attr_reader :actions, :namespace_name

    def initialize(module_name: '')
      @module_name = module_name
      @actions ||= Set.new
    end

    def scope(**options, &block)
      full_module_name = [module_name, options[:module]].reject(&:empty?).join('/')
      scoped_router = self.class.new(module_name: full_module_name)
      scoped_router.instance_eval(&block)
      actions.merge(scoped_router.actions)
    end

    def resources(name, **options, &block)
      builder_options = default_action_options.merge(options)
      actions_builder = ResourceActionsBuilder.new(name, **builder_options)
      actions_builder.instance_eval(&block) if block
      actions.merge(actions_builder.actions)
    end

    def query(name, **options)
      actions << build_action(QueryAction, name, **options)
    end

    def mutation(name, **options)
      actions << build_action(MutationAction, name, **options)
    end

    def graphql_schema
      SchemaBuilder.new(queries: actions.select(&:query?), mutations: actions.select(&:mutation?)).call
    end

    private

    attr_reader :module_name

    def build_action(action_builder, name, **options)
      action_options = default_action_options.merge(options)
      action_builder.new(name, action_options)
    end

    def default_action_options
      { module: module_name }
    end
  end
end
