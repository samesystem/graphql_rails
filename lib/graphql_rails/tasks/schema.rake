# frozen_string_literal: true

require 'graphql_rails/tasks/dump_graphql_schemas'

namespace :graphql_rails do
  namespace :schema do
    desc 'Dump GraphQL schema'
    task(dump: :environment) do |_, args|
      groups_from_args = args.extras
      groups_from_env = ENV['SCHEMA_GROUP_NAME'].to_s.split(',').map(&:strip)
      groups = groups_from_args + groups_from_env
      dump_dir = ENV.fetch('GRAPHQL_SCHEMA_DUMP_DIR') { Rails.root.join('spec/fixtures').to_s }

      GraphqlRails::DumpGraphqlSchemas.call(groups: groups, dump_dir: dump_dir)
    end
  end
end
