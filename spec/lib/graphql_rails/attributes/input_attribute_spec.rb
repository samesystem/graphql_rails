# frozen_string_literal: true

require 'spec_helper'

module GraphqlRails
  module Attributes
    RSpec.describe InputAttribute do
      subject(:attribute) { described_class.new(name, type) }

      let(:type) { 'String!' }
      let(:name) { 'full_name' }

      class DummyModel
        include GraphqlRails::Model

        graphql.input do |c|
          c.attribute :name
        end
      end

      describe '#graphql_input_type' do
        subject(:graphql_input_type) { attribute.graphql_input_type }

        context 'when type is basic scalar type' do
          it 'returns graphql scalar type' do
            expect(graphql_input_type).to eq(GraphQL::STRING_TYPE.to_non_null_type)
          end
        end

        context 'when type is instance of GrapqhlRails::Input' do
          let(:type) do
            DummyModel.graphql.input(:dummy_input) {}
          end

          it 'returns graphql input type' do
            expect(graphql_input_type).to eq type.graphql_input_type
          end
        end

        context 'when type is a raw grapqhl input class' do
          let(:type) do
            GraphQL::InputObjectType.define do
              name 'DummyInput'
            end
          end

          it 'returns orginal type' do
            expect(graphql_input_type).to eq type
          end
        end

        context 'when type refers to Graphql::Model' do
          let(:type) { DummyModel.name }

          it 'returns graphql input type' do
            expect(graphql_input_type).to eq DummyModel.graphql.input.graphql_input_type
          end
        end
      end

      describe '#graphql_field_type' do
        subject(:graphql_field_type) { attribute.graphql_field_type }

        context 'when type is not set' do
          let(:type) { nil }

          context 'when attribute name ends without bang mark (!)' do
            it { is_expected.not_to be_non_null }
          end

          context 'when attribute name ends with bang mark (!)' do
            let(:name) { :full_name! }

            it { is_expected.to be_non_null }
          end

          context 'when name ends with question mark (?)' do
            let(:name) { :admin? }

            it 'returns boolean type' do
              expect(graphql_field_type).to eq GraphQL::BOOLEAN_TYPE
            end
          end

          context 'when name ends with "id"' do
            let(:name) { :id }

            it 'returns id type' do
              expect(graphql_field_type).to eq GraphQL::ID_TYPE
            end
          end
        end

        context 'when attribute is required' do
          it { is_expected.to be_non_null }
        end

        context 'when attribute is optional' do
          let(:type) { 'String' }

          it { is_expected.not_to be_non_null }
        end

        context 'when attribute is array' do
          let(:type) { '[Int!]!' }

          context 'when array is required' do
            let(:type) { '[Int]!' }

            it { is_expected.to be_non_null }
            it { is_expected.to be_list }
          end

          context 'when inner type of array is required' do
            let(:type) { '[Int!]' }

            it { is_expected.not_to be_non_null }
            it { is_expected.to be_list }
          end

          context 'when array and its inner type is required' do
            it { is_expected.to be_non_null }
            it { is_expected.to be_list }
          end

          context 'when array and its inner type are optional' do
            let(:type) { '[Int]' }

            it { is_expected.not_to be_non_null }
            it { is_expected.to be_list }
          end
        end
      end
    end
  end
end
