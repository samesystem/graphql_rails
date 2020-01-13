# frozen_string_literal: true

require 'spec_helper'
require 'mongoid'
require 'active_record'

module GraphqlRails
  RSpec.describe Model do
    subject(:model) { plain_model }

    let(:plain_model) do
      Class.new do
        include GraphqlRails::Model

        graphql do |c|
          c.attribute :is_plain, type: :bool!
        end

        graphql.input do |c|
          c.attribute :parent_input_attribute
        end

        def self.name
          'DummyModel'
        end
      end
    end

    describe '.graphql' do
      it 'returns model configuration' do
        expect(model.graphql).to be_a(Model::Configuration)
      end

      context 'when inheritance is used' do
        subject(:model) do
          Class.new(plain_model) do
            graphql do |c|
              c.attribute :is_child, type: :bool!
            end

            graphql.input do |c|
              c.attribute :child_input_attribute
            end
          end
        end

        before do
          model
        end

        it 'does not modify parent class attributes' do
          parent_fields = plain_model.graphql.graphql_type.fields.keys
          expect(parent_fields).to match_array(%w[isPlain])
        end

        it 'inherits parent class graphql attributes' do
          child_fields = model.graphql.graphql_type.fields.keys
          expect(child_fields).to match_array(%w[isPlain isChild])
        end

        it 'does not modify parent class input attributes' do
          parent_fields = plain_model.graphql.input.graphql_input_type.arguments.keys
          expect(parent_fields).to match_array(%w[parentInputAttribute])
        end

        it 'inherits parent class graphql input attributes' do
          child_fields = model.graphql.input.graphql_input_type.arguments.keys
          expect(child_fields).to match_array(%w[childInputAttribute parentInputAttribute])
        end
      end
    end

    describe '#with_graphql_context' do
      it 'sets context in block' do
        model.new.with_graphql_context(data: 'context') do |with_context|
          expect(with_context.graphql_context).to eq(data: 'context')
        end
      end

      it 'removes context outside block' do
        item = model.new
        item.with_graphql_context(data: 'context') {}
        expect(item.graphql_context).to be_nil
      end
    end
  end
end
