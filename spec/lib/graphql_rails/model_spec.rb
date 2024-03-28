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
          c.attribute :amount, type: :integer!
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
          plain_model.graphql.graphql_type # force to set some configuration on parent class
          model
        end

        it 'does not modify parent class attributes' do
          parent_fields = plain_model.graphql.graphql_type.fields.keys
          expect(parent_fields).to match_array(%w[amount isPlain])
        end

        it 'inherits parent class graphql attributes' do
          child_fields = model.graphql.graphql_type.fields.keys
          expect(child_fields).to match_array(%w[amount isPlain isChild])
        end

        it 'does not inherit parent class graphql_type' do
          expect(model.graphql.graphql_type).not_to eq(plain_model.graphql.graphql_type)
        end

        it 'does not modify parent class input attributes' do
          parent_fields = plain_model.graphql.input.graphql_input_type.arguments.keys
          expect(parent_fields).to match_array(%w[parentInputAttribute])
        end

        it 'inherits parent class graphql input attributes' do
          child_fields = model.graphql.input.graphql_input_type.arguments.keys
          expect(child_fields).to match_array(%w[childInputAttribute parentInputAttribute])
        end

        context 'when redefining parent attribute' do
          subject(:model) do
            Class.new(plain_model) do
              graphql do |c|
                c.attribute :is_child, type: :bool!
                c.attribute :amount, type: :float!
              end
            end
          end

          it 'does not inherit parent attribute type' do
            require 'pry'; binding.pry
            amount_type = model.graphql.attributes['amount'].type

            expect(amount_type).to eq(:float!)
          end
        end
      end

      context 'when defining configuration' do
        let(:plain_model) do
          Class.new do
            include GraphqlRails::Model

            def self.name
              'DummyModel'
            end
          end
        end

        let(:graphql_stub) do
          instance_double(GraphqlRails::Model::Configuration, 'with_ensured_fields!' => true, attribute: nil)
        end

        context 'when configuration block is given' do
          it 'ensures correct fields' do
            plain_model.instance_variable_set(:@graphql, graphql_stub)
            plain_model.graphql do |g|
              g.attribute :id
            end
            expect(graphql_stub).to have_received(:with_ensured_fields!)
          end
        end

        context 'when configuration block is not given' do
          it 'does not ensure fields' do
            plain_model.instance_variable_set(:@graphql, graphql_stub)
            plain_model.graphql
            expect(graphql_stub).not_to have_received(:with_ensured_fields!)
          end
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
