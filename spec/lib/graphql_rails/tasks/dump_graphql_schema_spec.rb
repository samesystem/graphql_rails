# frozen_string_literal: true

require 'spec_helper'
require 'graphql_rails/tasks/dump_graphql_schema'

module GraphqlRails
  RSpec.describe DumpGraphqlSchema do
    subject(:dump_graphql_schema) { described_class.new(name: schema_name) }

    let(:schema_name) { nil }

    let(:fake_schema_path) { 'tmp/schema_path/schema.graphql' }

    before do
      # rubocop:disable RSpec/SubjectStub
      allow(dump_graphql_schema).to receive(:schema_path).and_return('tmp/schema_path/schema.graphql')
      # rubocop:enable RSpec/SubjectStub

      allow(File).to receive(:write).and_call_original
      allow(File).to receive(:write).with(fake_schema_path, kind_of(String)).and_return(1)
    end

    describe '#call' do
      subject(:call) { dump_graphql_schema.call }

      context 'when "GraphqlRouter" is defined' do
        let(:graphql_router) do
          GraphqlRails::Router.draw {}
        end

        before do
          stub_const('GraphqlRouter', graphql_router)
        end

        it 'writes router definition to file' do
          call
          expect(File).to have_received(:write).with(fake_schema_path, kind_of(String))
        end
      end

      context 'when "GraphqlRouter" is not defined' do
        it 'raises error' do
          expect { call }.to raise_error(
            'GraphqlRouter is missing. Run `rails g graphql_rails:install` to build it'
          )
        end
      end
    end
  end
end
