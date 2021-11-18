# frozen_string_literal: true

require 'graphql_rails/tasks/dump_graphql_schema'

namespace :graphql_rails do
  namespace :schema do
    desc 'Dump GraphQL schema'
    task(dump: :environment) do |_, args|
      groups_from_args = args.extras
      groups_from_env = ENV['SCHEMA_GROUP_NAME'].to_s.split(',').map(&:strip)
      groups = groups_from_args + groups_from_env

      GraphqlRails::DumpGraphqlSchemas.call(groups: groups)
    end
  end
end
