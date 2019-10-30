# frozen_string_literal: true

module GraphqlRails
  # Generates graphql schema dump files
  class DumpGraphqlSchema
    attr_reader :name

    def self.call(*args)
      new(*args).call
    end

    def initialize(name: '')
      @name = name
    end

    def call
      File.write(schema_path, schema.to_definition)
    end

    private

    def schema_name
      ['graphql', name.presence, 'schema'].compact.join('_')
    end

    def schema
      @schema ||= schema_name.camelize.safe_constantize
    end

    def schema_path
      schema_folder_path = Rails.root.join('spec', 'fixtures')
      FileUtils.mkdir_p(schema_folder_path)
      schema_folder_path.join("#{schema_name}.graphql")
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
