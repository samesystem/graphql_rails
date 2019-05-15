# frozen_string_literal: true

require 'spec_helper'
require 'mongoid'
require 'active_record'

module GraphqlRails
  RSpec.describe Model::Configuration do
    subject(:config) { model.graphql }

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

    describe '#graphql_type' do
      subject(:graphql_type) { config.graphql_type }

      context 'when model is simple ruby class' do
        it 'returns type with correct fields' do
          expect(graphql_type.fields.keys).to match_array(%w[id isValid level])
        end

        it 'includes field descriptions' do
          expect(graphql_type.fields.values.last.description).to eq 'over 9000!'
        end
      end

      context 'when type has description' do
        it 'adds same description in graphql type' do
          expect(graphql_type.description).to eq 'Used for test purposes'
        end
      end

      context 'when model has custom name' do
        let(:model) do
          Class.new do
            include GraphqlRails::Model

            graphql do |c|
              c.name 'ChangedName'
            end

            def self.name
              'DummyModelWithCustomName'
            end
          end
        end

        it 'returns correct name' do
          expect(graphql_type.name).to eq 'ChangedName'
        end
      end

      it 'returns instance of graphql  type' do
        expect(graphql_type).to be_a(GraphQL::ObjectType)
      end
    end

    describe '#connection_type' do
      subject(:connection_type) { config.connection_type }

      context 'when model is simple ruby class' do
        it 'returns Conection' do
          expect(connection_type.to_s).to eq('DummyModelConnection')
        end
      end
    end

    describe '#input' do
      subject(:input) { config.input(:new_input) }

      context 'when config block is not given' do
        it 'raises error' do
          expect { input }
            .to raise_error('GraphQL input with name :new_input is not defined for DummyModel')
        end
      end

      context 'when config block is given' do
        subject(:input) do
          config.input(:new_input) do |c|
            c.attribute :name
          end
        end

        it 'returns input instance' do
          expect(input).to be_a(Model::Input)
        end

        context 'when block is given second time for same input' do
          before do
            config.input(:new_input) do |c|
              c.attribute :second_name
            end
          end

          it 'extends existing input' do
            expect(input.attributes.keys).to match_array(%w[name second_name])
          end
        end
      end
    end
  end
end
