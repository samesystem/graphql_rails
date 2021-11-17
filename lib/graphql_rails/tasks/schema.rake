# frozen_string_literal: true

require 'graphql_rails/tasks/dump_graphql_schema'

namespace :graphql_rails do
  namespace :schema do
    desc 'Dump GraphQL schema'
    task(dump: :environment) do |_, args|
      names_from_args = args.extras
      names_from_env = ENV['SCHEMA_GROUP_NAME'].to_s.split(',').map(&:strip)

      group_names = names_from_args + names_from_env
      group_names = [''] if group_names.empty?

      group_names.each do |group_name|
        GraphqlRails::DumpGraphqlSchema.call(name: group_name)
      end
    end
  end
end
