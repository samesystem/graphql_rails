# frozen_string_literal: true

require 'active_support/core_ext/string/inflections'

require 'graphql_rails/router/schema_builder'
require 'graphql_rails/router/mutation_route'
require 'graphql_rails/router/query_route'
require 'graphql_rails/router/subscription_route'
require 'graphql_rails/router/resource_routes_builder'

module GraphqlRails
  # graphql router that mimics Rails.application.routes
  class Router
    RAW_ACTION_NAMES = %i[
      use rescue_from query_analyzer instrument cursor_encoder default_max_page_size
    ].freeze

    def self.draw(&block)
      new.tap do |router|
        router.instance_eval(&block)
      end
    end

    attr_reader :routes, :namespace_name, :raw_graphql_actions

    def initialize(module_name: '', group_names: [])
      @module_name = module_name
      @group_names = group_names
      @routes ||= Set.new
      @raw_graphql_actions ||= []
      @graphql_schema = {}
    end

    def group(*group_names, &block)
      scoped_router = router_with(group_names: group_names)
      scoped_router.instance_eval(&block)
      routes.merge(scoped_router.routes)
    end

    def scope(**options, &block)
      full_module_name = [module_name, options[:module]].reject(&:empty?).join('/')
      scoped_router = router_with(module_name: full_module_name)
      scoped_router.instance_eval(&block)
      routes.merge(scoped_router.routes)
    end

    def resources(name, **options, &block)
      builder_options = full_route_options(options)
      routes_builder = ResourceRoutesBuilder.new(name, **builder_options)
      routes_builder.instance_eval(&block) if block
      routes.merge(routes_builder.routes)
    end

    def query(name, **options)
      routes << build_route(QueryRoute, name, **options)
    end

    def mutation(name, **options)
      routes << build_route(MutationRoute, name, **options)
    end

    def subscription(name, **options)
      routes << build_route(SubscriptionRoute, name, **options)
    end

    RAW_ACTION_NAMES.each do |action_name|
      define_method(action_name) do |*args, &block|
        add_raw_action(action_name, *args, &block)
      end
    end

    def graphql_schema(group = nil)
      @graphql_schema[group&.to_sym] ||= SchemaBuilder.new(
        queries: routes.select(&:query?),
        mutations: routes.select(&:mutation?),
        subscriptions: routes.select(&:subscription?),
        raw_actions: raw_graphql_actions,
        group: group
      ).call
    end

    def reload_schema
      @graphql_schema.clear
    end

    private

    attr_reader :module_name, :group_names

    def router_with(new_router_options = {})
      default_options = { module_name: module_name, group_names: group_names }
      full_options = default_options.merge(new_router_options)

      self.class.new(**full_options)
    end

    def add_raw_action(name, *args, &block)
      raw_graphql_actions << { name: name, args: args, block: block }
    end

    def build_route(route_builder, name, **options)
      route_builder.new(name, **full_route_options(options))
    end

    def full_route_options(extra_options)
      extra_groups = Array(extra_options[:group]) + Array(extra_options[:groups])
      extra_options = extra_options.except(:group, :groups)
      groups = (group_names + extra_groups).uniq

      default_route_options.merge(extra_options).merge(groups: groups)
    end

    def default_route_options
      { module: module_name, on: :member }
    end
  end
end
