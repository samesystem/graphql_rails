# frozen_string_literal: true

require 'spec_helper'
require 'mongoid'
require 'active_record'

module GraphqlRails
  RSpec.describe Model::Configuration do
    class DummyModel
      include GraphqlRails::Model

      graphql do |c|
        c.description 'Used for test purposes'
        c.attribute :id
        c.attribute :valid?
        c.attribute :level, type: :int, description: 'over 9000!'
      end
    end

    class DummyModelWithCustomName < ActiveRecord::Base
      include GraphqlRails::Model

      graphql do |c|
        c.name 'ChangedName'
      end
    end

    subject(:config) { model.graphql }

    let(:model) { DummyModel }

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
        let(:model) { DummyModelWithCustomName }

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
  end
end
