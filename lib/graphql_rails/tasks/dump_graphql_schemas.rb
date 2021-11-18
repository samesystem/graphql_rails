# frozen_string_literal: true

require 'graphql_rails/tasks/dump_graphql_schema'

module GraphqlRails
  # Generates graphql schema dump files
  class DumpGraphqlSchemas
    require 'graphql_rails/errors/error'

    class MissingGraphqlRouterError < GraphqlRails::Error; end

    def self.call(**args)
      new(**args).call
    end

    def initialize(dump_dir:, groups: nil)
      @groups = groups.presence
      @dump_dir = dump_dir
    end

    def call
      validate
      return dump_default_schema if groups.empty?

      groups.each { |group| dump_graphql_schema(group) }
    end

    private

    attr_reader :dump_dir

    def dump_default_schema
      dump_graphql_schema('')
    end

    def dump_graphql_schema(group)
      DumpGraphqlSchema.call(group: group, router: router, dump_dir: dump_dir)
    end

    def validate
      return if router

      error_message = \
        'GraphqlRouter is missing. ' \
        'Run `rails g graphql_rails:install` to build it'
      raise MissingGraphqlRouterError, error_message
    end

    def router
      @router ||= '::GraphqlRouter'.safe_constantize
    end

    def groups
      @groups ||= router.routes.flat_map(&:groups).uniq
    end
  end
end
