# frozen_string_literal: true

require 'spec_helper'

module GraphqlRails
  module Attributes
    RSpec.describe InputAttribute do
      subject(:attribute) do
        described_class.new(name, config: config)
                       .with(type: type, options: options)
      end

      let(:config) { instance_double('GraphqlRails::Model::Input', name: 'DummyInput') }
      let(:type) { 'String!' }
      let(:name) { 'full_name' }
      let(:options) { {} }

      let(:dummy_model) do
        Class.new do
          include GraphqlRails::Model

          graphql.input do |c|
            c.attribute :name
          end

          def self.name
            'DummyModel'
          end
        end
      end

      before do
        stub_const('DummyModel', dummy_model)
      end

      describe '#type' do
        it 'changes input type' do
          expect { attribute.type(:int!) }.to change(attribute, :type).to(:int!)
        end
      end

      describe '#description' do
        it 'changes input type' do
          expect { attribute.description('this is my input') }
            .to change(attribute, :description).to('this is my input')
        end
      end

      describe '#enum' do
        it 'changes input type' do
          expect { attribute.enum(%w[this is enum]) }
            .to change(attribute, :enum).to(%w[this is enum])
        end
      end

      describe '#subtype' do
        it 'changes subtype' do
          expect { attribute.subtype('update') }
            .to change(attribute, :subtype).to('update')
        end
      end

      describe '#property' do
        it 'changes property' do
          expect { attribute.property('new_property') }
            .to change(attribute, :property).to('new_property')
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

        context 'when type is instance of GraphqlRails::Input' do
          let(:type) do
            dummy_model.graphql.input(:dummy_input) {}
          end

          it 'returns graphql input type' do
            expect(input_argument_type).to eq type.graphql_input_type
          end
        end

        context 'when type is a raw graphql input class' do
          let(:type) do
            Class.new(GraphQL::Schema::InputObject) do
              graphql_name 'DummyInput'
            end
          end

          context 'when input is not list' do
            it 'returns original type' do
              expect(input_argument_type).to eq type
            end
          end

          context 'when input is a list' do
            let(:type) { non_list_type.to_list_type }

            let(:non_list_type) do
              Class.new(GraphQL::Schema::InputObject) do
                graphql_name 'DummyAsListInput'
              end
            end

            it 'returns original type' do
              expect(input_argument_type).to eq [non_list_type, { null: true }]
            end
          end
        end

        context 'when type refers to Graphql::Model' do
          let(:type) { dummy_model.name }

          context 'when type is nullable' do
            it 'returns graphql input type' do
              expect(input_argument_type).to eq dummy_model.graphql.input.graphql_input_type
            end
          end

          context 'when type is not nullable' do
            let(:type) { "#{dummy_model.name}!" }

            it 'returns non nullable graphql input type' do
              expect(input_argument_type.to_type_signature).to eq 'DummyModelInput'
            end

            it 'marks input as required' do
              expect(input_argument_options[:required]).to be true
            end
          end

          context 'when type is not nullable array' do
            let(:type) { "[#{dummy_model.name}!]!" }

            it 'retuns as an array' do
              expect(input_argument_type).to be_an(Array)
            end

            it 'returns required input type', :aggregate_failures do
              expect(input_argument_type[0].to_type_signature).to eq 'DummyModelInput'
              expect(input_argument_type[1]).to be_nil
            end

            it 'marks input as required' do
              expect(input_argument_options[:required]).to be true
            end
          end

          context 'when list type is not nullable' do
            let(:type) { '[Int!]!' }

            it 'returns required input type', :aggregate_failures do
              expect(input_argument_type[0].to_type_signature).to eq 'Int'
              expect(input_argument_type[1]).to be_nil
            end

            it 'marks input as required' do
              expect(input_argument_options[:required]).to be true
            end
          end

          context 'when type is nullable array' do
            let(:type) { "[#{dummy_model.name}!]" }

            it 'contains required inner type', :aggregate_failures do
              expect(input_argument_type[0].to_type_signature).to eq 'DummyModelInput'
              expect(input_argument_type[1]).to be_nil
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

        context 'when input does not belong to any groups' do
          it 'builds field with empty groups' do
            expect(input_argument_options).to include(groups: [])
          end
        end

        context 'when input belongs to a group' do
          before do
            attribute.group(:some_group)
          end

          it 'builds field with a given group' do
            expect(input_argument_options).to include(groups: %w[some_group])
          end
        end

        context 'when input is hidden in a groups' do
          before do
            attribute.hidden_in_groups(:some_group)
          end

          it 'builds field with a given group' do
            expect(input_argument_options).to include(hidden_in_groups: %w[some_group])
          end
        end

        context 'when input is deprecated' do
          before do
            attribute.deprecated('Use something else')
          end

          it 'builds field with a given deprecation reason' do
            expect(input_argument_options).to include(deprecation_reason: 'Use something else')
          end
        end

        context 'when input has default value' do
          before do
            attribute.default_value('some value')
          end

          it 'builds field with a given default value' do
            expect(input_argument_options).to include(default_value: 'some value')
          end
        end

        context 'when input has property' do
          before do
            attribute.property('some_property')
          end

          it 'builds field with a given property' do
            expect(input_argument_options).to include(as: 'some_property')
          end
        end
      end
    end
  end
end
