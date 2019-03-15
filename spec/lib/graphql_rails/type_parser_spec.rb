# frozen_string_literal: true

require 'spec_helper'
require 'graphql_rails/type_parser'

module GraphqlRails
  RSpec.describe TypeParser do
    subject(:parser) { described_class.new(type) }

    let(:type) { 'String!' }

    describe '#call' do
      subject(:call) { parser.call }

      context 'when grapqhl type is provided' do
        let(:type) { GraphQL::INT_TYPE }

        it 'returns original grapqhl type' do
          expect(call).to eq type
        end
      end

      context 'when model type is provided' do
        let(:type) { 'SomeImage' }

        it 'returns grapqhl type defined on that model' do
          image = Object.const_set('SomeImage', Class.new { include GraphqlRails::Model })
          expect(call).to eq image.graphql.graphql_type
        end
      end

      context 'when attribute is required' do
        it { is_expected.to be_non_null }
      end

      context 'when attribute is optional' do
        let(:type) { 'String' }

        it { is_expected.not_to be_non_null }
      end

      context 'when attribute is integer' do
        let(:type) { 'Int' }

        it { is_expected.to be GraphQL::INT_TYPE }
      end

      context 'when attribute is ID' do
        let(:type) { 'ID' }

        it { is_expected.to be GraphQL::ID_TYPE }
      end

      context 'when attribute is boolean' do
        let(:type) { 'bool' }

        it { is_expected.to be GraphQL::BOOLEAN_TYPE }
      end

      context 'when attribute is float type' do
        let(:type) { 'float' }

        it { is_expected.to be GraphQL::FLOAT_TYPE }
      end

      context 'when attribute is not supported' do
        let(:type) { 'unknown' }

        it 'raises error' do
          expect { call }.to raise_error(TypeParser::UnknownTypeError)
        end
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
