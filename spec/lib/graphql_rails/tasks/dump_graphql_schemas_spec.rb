# frozen_string_literal: true

require 'spec_helper'
require 'graphql_rails/tasks/dump_graphql_schema'
require 'graphql_rails/tasks/dump_graphql_schemas'

module GraphqlRails
  RSpec.describe DumpGraphqlSchemas do
    subject(:dump_graphql_schema) { described_class.new(groups: groups, dump_dir: 'app/graphql') }

    let(:groups) { nil }

    describe '#call' do
      subject(:call) { dump_graphql_schema.call }

      let(:graphql_router) { GraphqlRails::Router.draw {} }

      let(:stub_router_constant) { stub_const('GraphqlRouter', graphql_router) }

      before do
        allow(DumpGraphqlSchema).to receive(:call).and_return(nil)
        stub_router_constant
      end

      context 'when groups are not given' do
        it 'dumps default schema', :aggregate_failures do
          call
          expect(DumpGraphqlSchema).to have_received(:call).once
          expect(DumpGraphqlSchema).to have_received(:call).with(hash_including(group: ''))
        end
      end

      context 'when groups are given' do
        let(:groups) { %w[group1 group2] }

        it 'dumps default schema', :aggregate_failures do
          call
          expect(DumpGraphqlSchema).to have_received(:call).twice
          expect(DumpGraphqlSchema).to have_received(:call).with(hash_including(group: 'group1'))
          expect(DumpGraphqlSchema).to have_received(:call).with(hash_including(group: 'group2'))
        end
      end

      context 'when "GraphqlRouter" is not defined' do
        let(:stub_router_constant) { nil }

        it 'raises error' do
          expect { call }.to raise_error(
            'GraphqlRouter is missing. Run `rails g graphql_rails:install` to build it'
          )
        end
      end
    end
  end
end
