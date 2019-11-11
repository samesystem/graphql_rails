# frozen_string_literal: true

require 'spec_helper'

module GraphqlRails
  module IntegrationTests
    RSpec.describe 'Integration: model with arguments' do
      class DummyModelItem
        include GraphqlRails::Model

        graphql.name 'IntegrationTestsDummyModelItem'
        graphql.attribute :name

        graphql.input { |c| c.attribute(:name) }

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
          c.attribute :field_with_args, type: DummyModelItem, permit: { name: :string! }
          c.attribute(:field_with_input_arg, type: DummyModelItem)
           .permit(input: DummyModelItem)

          c.attribute(:field_with_input_array_arg, type: "[#{DummyModelItem}!]!")
           .permit(inputs: "[#{DummyModelItem}!]!")

          c.attribute(:paginated_list_with_args, type: "[#{DummyModelItem}!]!")
           .permit(name: :string!)
           .paginated
        end

        def paginated_list
          Array.new(1000) { |i| DummyModelItem.new("Item ##{i + 1}") }
        end

        def field_with_args(name:)
          DummyModelItem.new(name)
        end

        def paginated_list_with_args(name:)
          Array.new(1000) { |i| DummyModelItem.new("Item #{name} ##{i + 1}") }
        end

        def field_with_input_arg(input:)
          DummyModelItem.new(input[:name])
        end

        def field_with_input_array_arg(inputs:)
          inputs.map { |input| DummyModelItem.new(input[:name]) }
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
        subject(:execute) { DummySchema.graphql_schema.execute(query) }

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
                  #{field_name}(#{inputs}) {
                    name
                  }
                }
              }
            GRAPHQL
          end

          let(:field_name) { 'fieldWithArgs' }
          let(:inputs) { 'name: "test"' }

          let(:response) do
            execute.to_h.dig('data', 'dummyModel', field_name)
          end

          context 'when argument is simple scalary type' do
            it 'passes arguments correctly' do
              expect(response).to eq('name' => 'test')
            end
          end

          context 'when argument is input type' do
            let(:field_name) { 'fieldWithInputArg' }
            let(:inputs) { 'input: { name: "test" }' }

            it 'passes arguments correctly' do
              expect(response).to eq('name' => 'test')
            end
          end

          context 'when argument is input array type' do
            let(:field_name) { 'fieldWithInputArrayArg' }
            let(:inputs) { 'inputs: [{ name: "test" }, { name: "test2" }]' }

            it 'passes arguments correctly' do
              expect(response)
                .to match_array([{ 'name' => 'test' }, { 'name' => 'test2' }])
            end
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
