# frozen_string_literal: true

require 'graphql_rails/tasks/dump_graphql_schema'

namespace :graphql_rails do
  namespace :schema do
    desc 'Dump GraphQL schema'
    task(:dump, %i[name] => :environment) do |_, args|
      args.with_defaults(name: '')
      GraphqlRails::DumpGraphqlSchema.call(name: args.name)
    end
  end
end
