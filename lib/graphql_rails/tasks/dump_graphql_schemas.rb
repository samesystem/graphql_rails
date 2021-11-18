# frozen_string_literal: true

module GraphqlRails
  # Generates graphql schema dump files
  class DumpGraphqlSchemas
    require 'graphql_rails/errors/error'

    class MissingGraphqlRouterError < GraphqlRails::Error; end

    attr_reader :name

    def self.call(**args)
      new(**args).call
    end

    def initialize(groups: [])
      @groups = groups.presence
    end

    def call
      validate
      return dump_default_schema if groups.empty?

      groups.each do |group|
        DumpGraphqlSchema.call(group: group)
      end
    end

    private

    def dump_default_schema
      DumpGraphqlSchema.call(group: '')
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
