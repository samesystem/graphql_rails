# frozen_string_literal: true

require 'spec_helper'

module GraphqlRails
  module Model
    RSpec.describe GraphqlInputTypeBuilder do
      subject(:builder) { described_class.new(name: name, description: description, attributes: attributes) }

      let(:name) { 'DummyInput' }
      let(:description) { 'This is dummy input' }
      let(:attributes) do
        {
          id: GraphqlRails::Model::InputAttribute.new(:id),
          full_name: GraphqlRails::Model::InputAttribute.new(:full_name!)
        }
      end

      describe '#call' do
        subject(:call) { builder.call }

        it 'returns graphql input class' do
          expect(call < ::GraphQL::Schema::InputObject).to be true
        end

        it 'sets correct name' do
          expect(call.graphql_name).to eq name
        end

        it 'sets correct description' do
          expect(call.description).to eq description
        end

        it 'sets correct attributes', :aggregate_failures do
          expect(call.arguments['fullName'].type).to be_non_null
          expect(call.arguments['id'].type).not_to be_non_null
        end
      end
    end
  end
end
