# frozen_string_literal: true

require 'spec_helper'

module GraphqlRails
  RSpec.describe ValidationError do
    subject(:validation_error) { described_class.new(short_message, field) }

    let(:short_message) { 'is invalid' }
    let(:field) { 'name' }

    describe '#message' do
      subject(:message) { validation_error.message }

      context 'when field is present' do
        it 'returns message with field name' do
          expect(message).to eq('Name is invalid')
        end
      end

      context 'when field is blank' do
        let(:field) { nil }

        it 'returns short message' do
          expect(message).to eq(short_message)
        end
      end

      context 'when field is "base"' do
        let(:field) { 'base' }

        it 'returns short message' do
          expect(message).to eq(short_message)
        end
      end
    end

    describe '#to_h' do
      subject(:to_h) { validation_error.to_h }

      it 'returns hash with error details' do # rubocop:disable RSpec/ExampleLength
        expect(to_h).to eq(
          'message' => 'Name is invalid',
          'type' => 'validation_error',
          'short_message' => short_message,
          'field' => field
        )
      end
    end
  end
end
