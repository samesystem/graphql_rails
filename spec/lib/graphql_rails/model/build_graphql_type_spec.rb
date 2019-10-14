# frozen_string_literal: true

require 'spec_helper'

module GraphqlRails
  module Model
    RSpec.describe BuildGraphqlType do
      describe '#call' do
        class DummyBuildGraphqlTypeName
          include Model

          graphql.attribute :name
        end

        subject(:call) do
          described_class.call(
            name: type_name,
            description: type_description,
            attributes: attributes
          )
        end

        let(:type_name) { 'DummyType' }
        let(:type_description) { 'This is my type!' }
        let(:attribute) { Attributes::Attribute.new('name', DummyBuildGraphqlTypeName.name) }
        let(:attributes) do
          {
            attribute.name => attribute
          }
        end

        context 'when attribute does not have any arguments' do
          it 'builds correct type' do
            expect(call.to_type_signature).to eq 'DummyType'
          end

          it 'builds type with correct fields' do
            expect(call.fields.keys).to match_array(%w[name])
          end

          it 'builds type without arguments' do
            expect(call.fields['name'].arguments).to be_empty
          end
        end

        context 'when attribute has arguments' do
          before do
            attribute.permit(length: :int!)
          end

          it 'builds correct type', :aggregate_failures do
            expect(call.to_type_signature).to eq 'DummyType'
          end

          it 'builds type with correct fields' do
            expect(call.fields.keys).to match_array(%w[name])
          end

          it 'builds type with correct arguments' do
            expect(call.fields['name'].arguments.keys).to match_array(%w[length])
          end
        end

        context 'when attribute is paginated' do
          before do
            attribute.paginated
          end

          it 'builds correct type', :aggregate_failures do
            expect(call.to_type_signature).to eq 'DummyType'
          end

          it 'builds type with correct fields' do
            expect(call.fields.keys).to match_array(%w[name])
          end

          it 'builds type with pagination arguments' do
            expect(call.fields['name'].arguments.keys).to match_array(%w[after before first last])
          end
        end
      end
    end
  end
end
