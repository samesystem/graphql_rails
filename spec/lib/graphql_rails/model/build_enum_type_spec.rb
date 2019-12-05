# frozen_string_literal: true

require 'spec_helper'

module GraphqlRails
  module Model
    RSpec.describe BuildEnumType do
      subject(:build_enum_type) do
        described_class.new(name, allowed_values: allowed_values, description: description)
      end

      let(:allowed_values) { [:yes, 'no'] }
      let(:name) { :my_enum }
      let(:description) { 'Enums are awesome!' }

      describe '#call' do
        subject(:call) { build_enum_type.call }

        it 'sets values with original mappings' do
          expect(call.values.transform_values(&:value)).to eq(
            'YES' => :yes,
            'NO' => 'no'
          )
        end

        it 'sets camelized name' do
          expect(call.graphql_name).to eq 'MyEnum'
        end

        it 'sets correct description' do
          expect(call.description).to eq description
        end

        context 'when allowed values are empty' do
          let(:allowed_values) { [] }

          it 'raises error' do
            expect { call }.to raise_error('At lest one enum option must be given')
          end
        end

        context 'when allowed values has wrong type' do
          let(:allowed_values) { 'Hey' }

          it 'raises error' do
            expect { call }.to raise_error('Enum must be instance of Array, but instance of String was given')
          end
        end
      end
    end
  end
end
