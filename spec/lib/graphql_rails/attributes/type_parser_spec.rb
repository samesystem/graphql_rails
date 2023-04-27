# frozen_string_literal: true

require 'spec_helper'

module GraphqlRails
  module Attributes
    RSpec.describe TypeParser do
      subject(:parser) { described_class.new(type) }

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
            Class.new do
              include GraphqlRails::Model
              graphql.attribute(:name)
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

        context 'when enum class is expressed as string' do
          let(:type) { 'SomeDummyEnum' }
          let(:type_class) do
            Class.new(GraphQL::Schema::Enum) do
              graphql_name "SomeDummyEnum#{SecureRandom.hex}"
              value 'OK', value: :ok
            end
          end

          before do
            Object.const_set('SomeDummyEnum', type_class)
          end

          it 'returns enum class', :aggregate_failures do
            expect(graphql_type_object).to eq type_class
          end
        end

        context 'when child class of GraphQL::Schema::Object expressed as string' do
          let(:type) { 'SomeImage' }
          let(:type_class) do
            Class.new(GraphQL::Schema::Object) do
              graphql_name "SomeImage#{SecureRandom.hex}"
            end
          end

          before do
            Object.const_set('SomeImage', type_class)
          end

          it 'returns original child class of  GraphQL::Schema::Object' do
            expect(graphql_type_object).to eq(type_class)
          end
        end

        context 'when child class of GraphQL::Schema::InputObject expressed as string' do
          let(:type) { '[SomeImageInput!]!' }
          let(:type_class) do
            Class.new(GraphQL::Schema::InputObject) do
              graphql_name "SomeImageInput#{SecureRandom.hex}"
              argument :date, type: GraphQL::Types::ISO8601Date, required: true
            end
          end

          before do
            Object.const_set('SomeImageInput', type_class)
          end

          it 'returns original child class of GraphQL::Schema::InputObject' do
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
            Class.new do
              include GraphqlRails::Model
              graphql.attribute(:name)
              graphql.name('Dummy')
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

      describe '#type_arg' do
        subject(:type_arg) { parser.type_arg }

        context 'when type is an array' do
          let(:type) { '[String!]!' }

          context 'when inner type is optional' do
            context 'when array is required' do
              let(:type) { '[String]!' }

              it 'returns correct structure' do
                expect(type_arg).to eq([GraphQL::Types::String, { null: true }])
              end
            end

            context 'when array is optional' do
              let(:type) { '[String]' }

              it 'returns correct structure' do
                expect(type_arg).to eq([GraphQL::Types::String, { null: true }])
              end
            end
          end
        end

        context 'when pagination is enabled' do
          let(:parser) { described_class.new(type, paginated: true) }

          context 'when type is not GraphqlRails::Model' do
            let(:type) { '[String!]!' }

            it 'raises error' do
              expect { type_arg }.to raise_error(/Unable to paginate "\[String!\]!"/)
            end
          end

          context 'when graphql_rails model is provided' do
            let(:type) do
              Class.new do
                include GraphqlRails::Model
                graphql.name 'Dummy'
                graphql.attribute(:name)
              end
            end

            it 'returns connection' do
              expect(type_arg < GraphQL::Types::Relay::BaseConnection).to be true
            end
          end
        end
      end

      describe '#graphql_type' do
        subject(:graphql_type) { parser.graphql_type }

        context 'when graphql type is provided' do
          let(:type) { GraphQL::Types::Int }

          it 'returns original graphql type' do
            expect(graphql_type).to eq type
          end
        end

        context 'when model type is provided' do
          let(:type) { 'SomeImage' }

          it 'returns graphql type defined on that model' do
            image = Object.const_set('SomeImage', Class.new { include GraphqlRails::Model })
            expect(graphql_type).to eq image.graphql.graphql_type
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

          it { is_expected.to be GraphQL::Types::Int }
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
            expect { graphql_type }.to raise_error(TypeParseable::UnknownTypeError)
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
end
