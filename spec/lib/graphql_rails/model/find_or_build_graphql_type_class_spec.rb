# frozen_string_literal: true

require 'spec_helper'

module GraphqlRails
  module Model
    RSpec.describe FindOrBuildGraphqlTypeClass do
      subject(:graphql_type_finder) do
        described_class.new(
          name: name,
          type_name: type_name,
          description: description,
          parent_class: GraphQL::Schema::Object,
          implements: implements
        )
      end

      let(:name) { 'DummyModel' }
      let(:type_name) { 'DummyModelType' }
      let(:description) { 'DummyModelTypeDescription' }
      let(:implements) { [] }

      describe '#klass' do
        subject(:klass) { graphql_type_finder.klass }

        context 'when graphql type with given type name exists' do
          let(:type_class) do
            graphql_type_name = name
            graphql_type_description = description

            Class.new(GraphQL::Schema::Object) do
              graphql_name(graphql_type_name)
              description(graphql_type_description)
            end
          end

          before do
            stub_const(type_name, type_class)
          end

          it 'returns graphql type found by graphql type name' do
            expect(klass).to eq(type_name.constantize)
          end

          it 'does not create new class', :aggregate_failures do
            klass
            expect(graphql_type_finder).not_to be_new_class
          end
        end

        context 'when graphql type with given type name does not exist' do
          it 'sets graphql name and description', :aggregate_failures do
            expect(klass.graphql_name).to eq(name)
            expect(klass.description).to eq(description)
            expect(graphql_type_finder).to be_new_class
          end
        end
      end
    end
  end
end
