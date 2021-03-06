# frozen_string_literal: true

require 'spec_helper'

module GraphqlRails
  module Attributes
    RSpec.describe InputAttribute do
      subject(:attribute) { described_class.new(name, type: type, options: options) }

      let(:type) { 'String!' }
      let(:name) { 'full_name' }
      let(:options) { {} }

      class DummyModel
        include GraphqlRails::Model

        graphql.input do |c|
          c.attribute :name
        end
      end

      describe '#input_argument_args' do
        subject(:input_argument_args) { attribute.input_argument_args }

        let(:input_argument_options) { attribute.input_argument_options }
        let(:input_argument_name) { input_argument_args[0] }
        let(:input_argument_type) { input_argument_args[1] }

        context 'when type is basic scalar type' do
          it 'returns graphql scalar type' do
            expect(input_argument_type).to eq(GraphQL::Types::String)
          end

          it 'returns required type' do
            expect(input_argument_options[:required]).to be true
          end
        end

        context 'when type is instance of GrapqhlRails::Input' do
          let(:type) do
            DummyModel.graphql.input(:dummy_input) {}
          end

          it 'returns graphql input type' do
            expect(input_argument_type).to eq type.graphql_input_type
          end
        end

        context 'when type is a raw grapqhl input class' do
          let(:type) do
            GraphQL::InputObjectType.define do
              name 'DummyInput'
            end
          end

          context 'when input is not list' do
            it 'returns orginal type' do
              expect(input_argument_type).to eq type
            end
          end

          context 'when input is a list' do
            let(:type) { non_list_type.to_list_type }

            let(:non_list_type) do
              GraphQL::InputObjectType.define do
                name 'DummyAsListInput'
              end
            end

            it 'returns orginal type' do
              expect(input_argument_type).to eq [non_list_type, { null: true }]
            end
          end
        end

        context 'when type refers to Graphql::Model' do
          let(:type) { DummyModel.name }

          context 'when type is nullable' do
            it 'returns graphql input type' do
              expect(input_argument_type).to eq DummyModel.graphql.input.graphql_input_type
            end
          end

          context 'when type is not nullable' do
            let(:type) { "#{DummyModel.name}!" }

            it 'returns non nullable graphql input type' do
              expect(input_argument_type.to_type_signature).to eq 'DummyModelInput'
            end

            it 'marks input as required' do
              expect(input_argument_options[:required]).to be true
            end
          end

          context 'when type is not nullable array' do
            let(:type) { "[#{DummyModel.name}!]!" }

            it 'retuns as an array' do
              expect(input_argument_type).to be_an(Array)
            end

            it 'returns required input type', :aggregate_failures do
              expect(input_argument_type.first.to_type_signature).to eq 'DummyModelInput'
              expect(input_argument_type.second).to be_nil
            end

            it 'marks input as required' do
              expect(input_argument_options[:required]).to be true
            end
          end

          context 'when list type is not nullable' do
            let(:type) { '[Int!]!' }

            it 'returns required input type', :aggregate_failures do
              expect(input_argument_type.first.to_type_signature).to eq 'Int'
              expect(input_argument_type.second).to be_nil
            end

            it 'marks input as required' do
              expect(input_argument_options[:required]).to be true
            end
          end

          context 'when type is nullable array' do
            let(:type) { "[#{DummyModel.name}!]" }

            it 'contains required inner type', :aggregate_failures do
              expect(input_argument_type.first.to_type_signature).to eq 'DummyModelInput'
              expect(input_argument_type.second).to be_nil
            end

            it 'marks list part as not required' do
              expect(input_argument_options[:required]).to be false
            end
          end

          context 'when input_format option is given' do
            let(:options) { { input_format: :original } }

            it 'takes in to account input format options' do
              expect(input_argument_name).to eq 'full_name'
            end
          end
        end
      end
    end
  end
end
