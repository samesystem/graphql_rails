# frozen_string_literal: true

require 'spec_helper'

module GraphqlRails
  module Attributes
    RSpec.describe InputTypeParser do
      subject(:parser) { described_class.new(type, subtype: subtype) }

      let(:subtype) { nil }
      let(:type) { 'String!' }

      describe '#graphql_model' do
        subject(:graphql_model) { parser.graphql_model }

        context 'when custom type is provided' do
          let(:type) { 'SomeImage' }

          it 'returns custom model' do
            image = Object.const_set('SomeImage', Class.new { include GraphqlRails::Model })
            expect(graphql_model).to eq(image)
          end
        end

        context 'when graphql type is provided' do
          let(:type) { GraphQL::Types::Int }

          it { is_expected.to be_nil }
        end

        context 'when graphql_rails model is provided' do
          let(:type) do
            input_subtype = subtype

            Class.new do
              include GraphqlRails::Model

              graphql.name 'Dummy'

              graphql.input(input_subtype) do |c|
                c.attribute(:name)
              end
            end
          end

          it 'returns original type' do
            expect(graphql_model).to be(type)
          end
        end

        context 'when standard type is provided' do
          it { is_expected.to be_nil }
        end
      end

      describe '#graphql_type_object' do
        subject(:graphql_type_object) { parser.graphql_type_object }

        context 'when custom type is GraphQL::Schema::Scalar expressed as string' do
          let(:type) { '::GraphQL::Types::ISO8601Date!' }

          it 'returns raw GraphQL::Schema::Scalar', :aggregate_failures do
            expect(graphql_type_object).to eq ::GraphQL::Types::ISO8601Date
          end
        end

        context 'when custom type is GraphQL::Schema::Object expressed as string' do
          let(:type) { 'SomeImage' }
          let(:type_class) do
            Class.new(GraphQL::Schema::Object) do
              graphql_name "SomeImage#{SecureRandom.hex}"
            end
          end

          before do
            Object.const_set('SomeImage', type_class)
          end

          it 'returns original GraphQL::Schema::Object' do
            expect(graphql_type_object).to eq(type_class)
          end
        end

        context 'when raw graphql scalar type is provided' do
          let(:type) { GraphQL::Types::Int }

          it 'returns given scalar type' do
            expect(graphql_type_object).to eq(type)
          end
        end

        context 'when graphql_rails model is provided' do
          let(:type) do
            input_subtype = subtype

            Class.new do
              include GraphqlRails::Model

              graphql.name 'Dummy'

              graphql.input(input_subtype) do |c|
                c.name('DummyInput')
                c.attribute(:name)
              end
            end
          end

          it 'returns model graphql type' do
            expect(graphql_type_object).to be(type.graphql.graphql_type)
          end
        end

        context 'when standard type is provided' do
          it { is_expected.to be_nil }
        end
      end

      describe '#input_type_arg' do
        subject(:input_type_arg) { parser.input_type_arg }

        context 'when graphql type is provided' do
          let(:type) { GraphQL::INT_TYPE }

          it 'returns original graphql type' do
            expect(input_type_arg).to eq type
          end
        end

        context 'when model type is provided' do
          let(:type) { 'SomeImage' }

          let(:type_class) do
            Class.new do
              include GraphqlRails::Model

              graphql.name("SomeImage#{SecureRandom.hex}")
              graphql.input do |c|
                c.attribute(:url)
              end
            end
          end

          before do
            stub_const('SomeImage', type_class)
          end

          it 'returns graphql type defined on that model' do
            expect(input_type_arg.inspect).to eq 'GraphQL::Schema::InputObject(SomeImageInput)'
          end
        end

        context 'when attribute is required' do
          it 'returns raw type' do
            expect(input_type_arg).to eq GraphQL::Types::String
          end
        end

        context 'when attribute is optional' do
          let(:type) { 'String' }

          it 'includes graphql string type' do
            expect(input_type_arg).to eq GraphQL::Types::String
          end
        end

        context 'when attribute is integer' do
          let(:type) { 'Int' }

          it 'returns graphql integer type' do
            expect(input_type_arg).to eq GraphQL::Types::Int
          end
        end

        context 'when attribute is ID' do
          let(:type) { 'ID' }

          it { is_expected.to be GraphQL::Types::ID }
        end

        context 'when attribute is boolean' do
          let(:type) { 'bool' }

          it { is_expected.to be GraphQL::Types::Boolean }
        end

        context 'when attribute is float type' do
          let(:type) { 'float' }

          it { is_expected.to be GraphQL::Types::Float }
        end

        context 'when attribute is not supported' do
          let(:type) { 'unknown' }

          it 'raises error' do
            expect { input_type_arg }.to raise_error(TypeParseable::UnknownTypeError)
          end
        end

        context 'when attribute is array' do
          let(:type) { '[Int!]!' }

          context 'when array is required' do
            let(:type) { '[Int]!' }

            it 'returns array with "null: true" flag' do
              expect(input_type_arg).to eq [GraphQL::Types::Int, { null: true }]
            end
          end

          context 'when inner type of array is required' do
            let(:type) { '[Int!]' }

            it 'returns array without "null" flag' do
              expect(input_type_arg).to eq [GraphQL::Types::Int]
            end
          end

          context 'when array and its inner type is required' do
            it 'returns array without "null" flag' do
              expect(input_type_arg).to eq [GraphQL::Types::Int]
            end
          end

          context 'when array and its inner type are optional' do
            let(:type) { '[Int]' }

            it 'returns array with "null: true" flag' do
              expect(input_type_arg).to eq [GraphQL::Types::Int, { null: true }]
            end
          end
        end
      end
    end
  end
end
