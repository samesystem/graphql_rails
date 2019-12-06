# frozen_string_literal: true

require 'graphql_rails/tasks/dump_graphql_schema'

namespace :graphql_rails do
  namespace :schema do
    desc 'Dump GraphQL schema'
    task(:dump, %i[name] => :environment) do |_, args|
      default_name = ENV.fetch('SCHEMA_GROUP_NAME', '')
      args.with_defaults(name: default_name)
      GraphqlRails::DumpGraphqlSchema.call(name: args.name)
    end
  end
end
