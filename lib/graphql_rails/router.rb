# frozen_string_literal: true

require 'active_support/core_ext/string/inflections'

require 'graphql_rails/router/schema_builder'
require 'graphql_rails/router/mutation_route'
require 'graphql_rails/router/query_route'
require 'graphql_rails/router/event_route'
require 'graphql_rails/router/resource_routes_builder'

module GraphqlRails
  # graphql router that mimics Rails.application.routes
  class Router
    RAW_ACTION_NAMES = %i[
      use rescue_from query_analyzer instrument cursor_encoder default_max_page_size tracer trace_with
    ].freeze

    def self.draw(&block)
      new.tap do |router|
        router.instance_eval(&block)
      end
    end

    attr_reader :routes, :namespace_name, :raw_graphql_actions, :scope_names

    def initialize(module_name: '', group_names: [], scope_names: [])
      @scope_names = scope_names
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

    def scope(new_scope_name = nil, **options, &block)
      scoped_router = router_with_scope_params(new_scope_name, **options)
      scoped_router.instance_eval(&block)
      routes.merge(scoped_router.routes)
    end

    def namespace(namespace_name, &block)
      scope(path: namespace_name, module: namespace_name, &block)
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

    def event(name, **options)
      routes << build_route(EventRoute, name, **options)
    end

    RAW_ACTION_NAMES.each do |action_name|
      define_method(action_name) do |*args, **kwargs, &block|
        add_raw_action(action_name, *args, **kwargs, &block)
      end
    end

    def graphql_schema(group = nil)
      @graphql_schema[group&.to_sym] ||= SchemaBuilder.new(
        queries: routes.select(&:query?),
        mutations: routes.select(&:mutation?),
        events: routes.select(&:event?),
        raw_actions: raw_graphql_actions,
        group: group
      ).call
    end

    def reload_schema
      @graphql_schema.clear
    end

    private

    attr_reader :module_name, :group_names

    def router_with_scope_params(new_scope_name, **options)
      new_scope_name ||= options[:path]

      full_module_name = [module_name, options[:module]].select(&:present?).join('/')
      full_scope_names = [*scope_names, new_scope_name].select(&:present?)

      router_with(module_name: full_module_name, scope_names: full_scope_names)
    end

    def router_with(new_router_options = {})
      full_options = default_router_options.merge(new_router_options)

      self.class.new(**full_options)
    end

    def default_router_options
      { module_name: module_name, group_names: group_names, scope_names: scope_names }
    end

    def add_raw_action(name, *args, **kwargs, &block)
      raw_graphql_actions << { name: name, args: args, kwargs: kwargs, block: block }
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
      { module: module_name, on: :member, scope_names: scope_names }
    end
  end
end
