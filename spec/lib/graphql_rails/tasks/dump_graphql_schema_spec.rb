# frozen_string_literal: true

require 'spec_helper'
require 'graphql_rails/tasks/dump_graphql_schema'

module GraphqlRails
  RSpec.describe DumpGraphqlSchema do
    subject(:dump_graphql_schema) { described_class.new(group: group, router: graphql_router) }

    let(:group) { nil }
    let(:default_schema_path) { 'app/spec/fixtures/graphql_schema.graphql' }

    let(:graphql_router) do
      GraphqlRails::Router.draw {}
    end

    before do
      # rubocop:disable RSpec/SubjectStub
      allow(dump_graphql_schema).to receive(:root_path).and_return('app')
      # rubocop:enable RSpec/SubjectStub

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

        it 'writes router definition to group schema file' do
          call
          expected_path = "app/spec/fixtures/graphql_custom_schema.graphql"
          expect(File).to have_received(:write).with(expected_path, kind_of(String))
        end
      end

      context 'when GRAPHQL_SCHEMA_DUMP_PATH ENV variable is not set' do
        it 'writes router definition to file' do
          call
          expect(File).to have_received(:write).with(default_schema_path, kind_of(String))
        end
      end

      context 'when GRAPHQL_SCHEMA_DUMP_PATH ENV variable is set' do
        let(:env_schema_path) { 'tmp/schema_path/env_schema.graphql' }

        before do
          allow(ENV).to receive(:[]).and_call_original
          allow(ENV).to receive(:[]).with('GRAPHQL_SCHEMA_DUMP_PATH').and_return(env_schema_path)
          allow(File).to receive(:write).with(env_schema_path, kind_of(String)).and_return(1)
        end

        it 'writes router definition to file defined in ENV variable' do
          call
          expect(File).to have_received(:write).with(env_schema_path, kind_of(String))
        end

        it 'does not write router definition to default file' do
          call
          expect(File).not_to have_received(:write).with(default_schema_path, kind_of(String))
        end
      end
    end
  end
end
