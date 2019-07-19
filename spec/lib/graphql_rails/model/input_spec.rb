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
        context 'when attribute has enum type' do
          before do
            input.attribute(:fruit, enum: %i[apple orange])
          end

          it 'adds attribute with enum type' do
            expect(input.attributes['fruit'].graphql_field_type < GraphQL::Schema::Enum).to be true
          end
        end
      end

      describe '#graphql_input_type' do
        subject(:graphql_input_type) { input.graphql_input_type }

        before do
          input.attribute(:first_name, type: :string!)
          input.attribute(:last_name, type: :string!)
        end

        context 'with attributes' do
          it 'returns graphql input with arguments' do
            expect(graphql_input_type.arguments.keys).to match_array(%w[firstName lastName])
          end
        end
      end
    end
  end
end
