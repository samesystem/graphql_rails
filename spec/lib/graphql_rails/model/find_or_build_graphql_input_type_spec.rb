# frozen_string_literal: true

require 'spec_helper'

module GraphqlRails
  module Model
    RSpec.describe FindOrBuildGraphqlInputType do
      subject(:builder) do
        described_class.new(
          name: name,
          type_name: name.constantize.graphql.input.type_name,
          description: description,
          attributes: attributes
        )
      end

      let(:name) { 'DummyInput' }
      let(:description) { 'This is dummy input' }
      let(:attributes) do
        {
          id: GraphqlRails::Attributes::InputAttribute.new(:id, config: nil),
          full_name: GraphqlRails::Attributes::InputAttribute.new(:full_name!, config: nil)
        }
      end

      let(:dummy_model_class) do
        graphql_name = name
        graphql_description = description

        Class.new do
          include Model

          graphql.input do |c|
            c.name graphql_name
            c.description graphql_description
            c.attribute :name
          end
        end
      end

      before do
        stub_const(name, dummy_model_class)
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
