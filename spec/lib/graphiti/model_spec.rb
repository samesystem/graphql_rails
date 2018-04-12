require 'spec_helper'

module Graphiti
  RSpec.describe Model do
    class DummyModel
      include Graphiti::Model

      graphiti do |c|
        c.attribute :id
        c.attribute :name
        c.attribute :level, :int
      end
    end

    subject(:model) { DummyModel }

    describe '.graphql_type' do
      it 'returns type with correct fields' do
        expect(model.graphiti.graphql_type.fields.keys).to match_array(%w[id name level])
      end

      it 'returns instance of graphql  type' do
        expect(model.graphiti.graphql_type).to be_a(GraphQL::ObjectType)
      end
    end
  end
end
