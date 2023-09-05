# frozen_string_literal: true

require 'spec_helper'

module GraphqlRails
  module Model
    RSpec.describe Input do
      subject(:input) { described_class.new(model, input_name) }

      let(:input_name) { :search_criteria }

      let(:model) do
        Class.new do
          include GraphqlRails::Model

          graphql do |c|
            c.description 'Used for test purposes'
            c.attribute :id
            c.attribute :valid?
            c.attribute :level, type: :int, description: 'over 9000!'
          end

          def self.name
            'DummyModel'
          end
        end
      end

      describe '#name' do
        it 'joins model name and input name' do
          expect(input.name).to eq 'DummyModelSearchCriteriaInput'
        end
      end

      describe '#attribute' do
        let(:attribute_type) { input.attributes['fruit'].input_argument_args[1] }
        let(:attribute_type_options) { input.attributes['fruit'].input_argument_options }

        context 'when attribute has enum type' do
          context 'when enum is required' do
            before do
              input.attribute(:fruit, enum: %i[apple orange], required: true)
            end

            it 'adds non null enum type' do
              expect(attribute_type_options).to include(required: true)
            end

            it 'adds attribute with enum type' do
              expect(attribute_type < GraphQL::Schema::Enum).to be true
            end
          end

          context 'when enum is not required' do
            before do
              input.attribute(:fruit, enum: %i[apple orange])
            end

            it 'adds not required enum type' do
              expect(attribute_type_options).to include(required: false)
            end

            it 'adds attribute with enum type' do
              expect(attribute_type < GraphQL::Schema::Enum).to be true
            end
          end
        end
      end

      describe '#graphql_input_type' do
        subject(:graphql_input_type) { input.graphql_input_type }

        context 'with attributes' do
          before do
            input.attribute(:first_name, type: :string!)
            input.attribute(:last_name, type: :string!)
          end

          it 'returns graphql input with arguments' do
            expect(graphql_input_type.arguments.keys).to match_array(%w[firstName lastName])
          end
        end

        context 'when attribute points to another graphql input' do
          module InputSpec # rubocop:disable Lint/LeakyConstantDeclaration, Lint/ConstantDefinitionInBlock
            class ChildModel # rubocop:disable Lint/LeakyConstantDeclaration
              include GraphqlRails::Model

              graphql do |c|
                c.attribute(:something)
              end

              graphql.input(:update) do |c|
                c.attribute(:name).type('String!')
              end
            end

            class ParentModel # rubocop:disable Lint/LeakyConstantDeclaration
              include GraphqlRails::Model

              graphql.input do |c|
                c.attribute(:child)
                 .type("[#{InputSpec::ChildModel}!]")
                 .subtype(:update)
              end
            end
          end

          let(:input) { InputSpec::ParentModel.graphql.input }

          it 'returns correct graphql input type' do
            expect(graphql_input_type.arguments['child'].type.unwrap)
              .to eq(InputSpec::ChildModel.graphql.input(:update).graphql_input_type)
          end
        end
      end
    end
  end
end
