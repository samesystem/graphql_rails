require 'spec_helper'

module Graphiti
  RSpec.describe Model do
    class DummyModel
      include Graphiti::Model

      attribute :name
      attribute :level, :int
    end

    subject(:model) { DummyModel }

    describe '.graphql_type' do
      it 'returns type with correct fields' do
        expect(model.graphql_type.fields.keys).to match_array(%w[name level])
      end

      it 'returns instance of graphql  type' do
        expect(model.graphql_type).to be_a(GraphQL::ObjectType)
      end
    end
  end
end
