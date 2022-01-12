# frozen_string_literal: true

module GraphqlRails
  # Generates graphql schema dump files
  class DumpGraphqlSchema
    require 'graphql_rails/errors/error'

    class MissingGraphqlRouterError < GraphqlRails::Error; end

    def self.call(**args)
      new(**args).call
    end

    def initialize(group:, router:, dump_dir: nil)
      @group = group
      @router = router
      @dump_dir = dump_dir
    end

    def call
      File.write(schema_path, schema_dump)
    end

    private

    attr_reader :router, :group

    def schema_dump
      context = { graphql_group: group }
      schema.to_definition(context: context)
    end

    def schema
      @schema ||= router.graphql_schema(group.presence)
    end

    def schema_path
      FileUtils.mkdir_p(dump_dir)
      file_name = group.present? ? "graphql_#{group}_schema.graphql" : 'graphql_schema.graphql'

      "#{dump_dir}/#{file_name}"
    end

    def dump_dir
      @dump_dir ||= Rails.root.join('spec/fixtures').to_s
    end
  end
end
