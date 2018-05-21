# frozen_string_literal: true

require 'spec_helper'
require 'mongoid'
require 'active_record'

module GraphqlRails
  RSpec.describe Model::Configuration do
    class DummyModel
      include GraphqlRails::Model

      graphql do |c|
        c.attribute :id
        c.attribute :valid?
        c.attribute :level, type: :int
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

    describe '.graphql_type' do
      context 'when model is simple ruby class' do
        it 'returns type with correct fields' do
          expect(model.graphql.graphql_type.fields.keys).to match_array(%w[id isValid level])
        end
      end

      context 'when model has custom name' do
        let(:model) { DummyModelWithCustomName }

        it 'returns correct name' do
          expect(config.graphql_type.name).to eq 'ChangedName'
        end
      end

      it 'returns instance of graphql  type' do
        expect(config.graphql_type).to be_a(GraphQL::ObjectType)
      end
    end
  end
end
