# frozen_string_literal: true

require 'spec_helper'
require 'graphql_rails/tasks/dump_graphql_schema'

module GraphqlRails
  RSpec.describe DumpGraphqlSchema do
    subject(:dump_graphql_schema) do
      described_class.new(group: group, router: graphql_router, dump_dir: 'app/graphql')
    end

    let(:group) { nil }
    let(:default_schema_path) { 'app/graphql/graphql_schema.graphql' }

    let(:graphql_router) do
      GraphqlRails::Router.draw {}
    end

    before do
      allow(FileUtils).to receive(:mkdir_p).and_return(nil)
      allow(File).to receive(:write).and_return(1)
    end

    describe '#call' do
      subject(:call) { dump_graphql_schema.call }

      context 'when group is blank' do
        it 'writes router definition to default schema file' do
          call
          expect(File).to have_received(:write).with(default_schema_path, kind_of(String))
        end
      end

      context 'when group name is given' do
        let(:group) { 'custom' }
        let(:schema_double) { double('Schema') } # rubocop:disable RSpec/VerifiedDoubles
        let(:graphql_router) { instance_double('GraphqlRails::Router', graphql_schema: schema_double) }

        before do
          allow(graphql_router).to receive(:graphql_schema).and_return(schema_double)
          allow(schema_double).to receive(:to_definition).and_return('')
        end

        it 'dumps schema with group context', :aggregate_failures do
          call
          expect(graphql_router).to have_received(:graphql_schema).with('custom')
          expect(schema_double).to have_received(:to_definition).with(context: { graphql_group: 'custom' })
        end

        it 'writes router definition to group schema file' do
          call
          expected_path = 'app/graphql/graphql_custom_schema.graphql'
          expect(File).to have_received(:write).with(expected_path, kind_of(String))
        end
      end
    end
  end
end
