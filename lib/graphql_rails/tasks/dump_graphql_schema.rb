# frozen_string_literal: true

module GraphqlRails
  # Generates graphql schema dump files
  class DumpGraphqlSchema
    require 'graphql_rails/errors/error'

    class MissingGraphqlRouterError < GraphqlRails::Error; end

    def self.call(**args)
      new(**args).call
    end

    def initialize(group:, router:)
      @group = group
      @router = router
    end

    def call
      File.write(schema_path, schema.to_definition)
    end

    private

    attr_reader :router, :group

    def schema
      @schema ||= router.graphql_schema(group.presence)
    end

    def schema_path
      ENV['GRAPHQL_SCHEMA_DUMP_PATH'] || default_schema_path
    end

    def default_schema_path
      schema_folder_path = "#{root_path}/spec/fixtures"

      FileUtils.mkdir_p(schema_folder_path)
      file_name = group.present? ? "graphql_#{group}_schema.graphql" : 'graphql_schema.graphql'

      "#{schema_folder_path}/#{file_name}"
    end

    def root_path
      Rails.root
    end
  end
end
