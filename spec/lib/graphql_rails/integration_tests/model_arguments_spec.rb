# frozen_string_literal: true

require 'spec_helper'

module GraphqlRails
  module IntegrationTests
    RSpec.describe 'Integration: model with arguments' do
      class DummyModelItem
        include GraphqlRails::Model

        graphql.name "IntegrationTestsDummyModelItem"
        graphql.attribute :name

        attr_reader :name

        def initialize(name)
          @name = name
        end
      end

      class DummyModel
        include GraphqlRails::Model

        graphql do |c|
          c.description 'Used for test purposes'
          c.attribute :paginated_list, type: "[#{DummyModelItem}!]!", paginated: true
          c.attribute :field_with_args, permit: { name: :string! }
          c.attribute(:paginated_list_with_args, type: "[#{DummyModelItem}!]!")
           .permit(name: :string!)
           .paginated
        end

        def paginated_list
          Array.new(1000) { |i| DummyModelItem.new("Item ##{i + 1}") }
        end

        def field_with_args(name:)
          "hello #{name}!"
        end

        def paginated_list_with_args(name:)
          Array.new(1000) { |i| DummyModelItem.new("Item #{name} ##{i + 1}") }
        end
      end

      class DummyModelsController < GraphqlRails::Controller
        model(DummyModel.to_s)

        action(:show).returns_single

        def show
          DummyModel.new
        end
      end

      DummySchema = Router.draw do
        scope module: :graphql_rails do
          scope module: :integration_tests do
            resources :dummy_models, only: :show
          end
        end
      end

      describe 'Model#attribute' do
        subject(:execute) { DummySchema.execute(query) }

        let(:query) do
          <<~GRAPHQL
            query {
              dummyModel {
                paginatedList(first: 3) {
                  edges {
                   node {
                     name
                   }
                  }
                }
              }
            }
          GRAPHQL
        end

        let(:response) do
          nodes = execute.to_h.dig('data', 'dummyModel', 'paginatedList', 'edges')
          nodes.map { |node| node['node']['name'] }
        end

        context 'when attribute is paginated' do
          it 'paginates correctly' do
            expect(response).to eq ['Item #1', 'Item #2', 'Item #3']
          end
        end

        context 'when attribute accepts arguments' do
          let(:query) do
            <<~GRAPHQL
              query {
                dummyModel {
                  fieldWithArgs(name: "test")
                }
              }
            GRAPHQL
          end

          let(:response) do
            execute.to_h.dig('data', 'dummyModel', 'fieldWithArgs')
          end

          it 'passes arguments correctly' do
            expect(response).to eq 'hello test!'
          end
        end

        context 'when attribute is paginated and accepts arguments' do
          let(:query) do
            <<~GRAPHQL
              query {
                dummyModel {
                  paginatedListWithArgs(last: 3, name: "test") {
                    edges {
                      node {
                        name
                      }
                    }
                  }
                }
              }
            GRAPHQL
          end

          let(:response) do
            nodes = execute.to_h.dig('data', 'dummyModel', 'paginatedListWithArgs', 'edges')
            nodes.map { |node| node['node']['name'] }
          end

          it 'passes arguments and paginates correctly' do
            expect(response).to eq ['Item test #998', 'Item test #999', 'Item test #1000']
          end
        end
      end
    end
  end
end
