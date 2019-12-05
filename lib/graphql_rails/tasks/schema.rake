# frozen_string_literal: true

module GraphqlRails
  # Generates graphql schema dump files
  class DumpGraphqlSchema
    require 'graphql_rails/errors/error'

    class MissingGraphqlRouterError < GraphqlRails::Error; end

    attr_reader :name

    def self.call(*args)
      new(*args).call
    end

    def initialize(name:)
      @name = name
    end

    def call
      validate
      File.write(schema_path, schema.to_definition)
    end

    private

    def validate
      return if defined?(::GraphqlRouter)

      error_message = \
        'GraphqlRouter is missing. ' \
        'Run `rails g graphql_rails:install` to build it'
      raise MissingGraphqlRouterError, error_message
    end

    def schema
      @schema ||= ::GraphqlRouter.graphql_schema(name.presence)
    end

    def schema_path
      ENV['GRAPHQL_SCHEMA_DUMP_PATH'] || default_schema_path
    end

    def default_schema_path
      schema_folder_path = Rails.root.join('spec', 'fixtures')

      FileUtils.mkdir_p(schema_folder_path)
      file_name = name.present? ? "graphql_#{name}_schema.graphql" : 'graphql_schema.graphql'

      schema_folder_path.join(file_name)
    end
  end
end

namespace :graphql_rails do
  namespace :schema do
    desc 'Dump GraphQL schema'
    task(:dump, %i[name] => :environment) do |_, args|
      args.with_defaults(name: '')
      GraphqlRails::DumpGraphqlSchema.call(name: args.name)
    end
  end
end
