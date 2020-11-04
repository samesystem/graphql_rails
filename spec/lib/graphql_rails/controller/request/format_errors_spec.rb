# frozen_string_literal: true

require 'spec_helper'
require 'active_model'

module GraphqlRails
  RSpec.describe Controller::Request::FormatErrors do
    subject(:format_errors) { described_class.new(not_formatted_errors: errors) }

    let(:errors) { ['boom!'] }

    describe '#call' do
      subject(:call) { format_errors.call }

      context 'when errors are simple strings' do
        it 'returns ExecutionError instances' do
          expect(call.first).to be_a(ExecutionError)
        end

        it 'moves string values to error messages' do
          expect(call.first.message).to eq('boom!')
        end
      end

      context 'when errors are hash' do
        let(:errors) { [{ message: 'Boom!', code: 1337, type: 'testing_error' }] }

        it 'returns errors as instances of CustomExecutionError' do
          expect(call.first).to be_a(CustomExecutionError)
        end

        it 'includes all the information from hash' do
          expect(call.first.to_h).to eq(
            'message' => 'Boom!',
            'code' => 1337,
            'type' => 'testing_error'
          )
        end
      end

      context 'when errors are ActiveModel::Errors' do
        let(:errors) do
          ActiveModel::Errors.new({}).tap do |errors|
            errors.add(:test, 'boom!')
          end
        end

        it 'returns errors as instances of ValidationError' do
          expect(call.first).to be_a(ValidationError)
        end

        it 'all the information', :aggregate_failures do
          error = call.first
          expect(error.message).to eq('Test boom!')
          expect(error.type).to eq('validation_error')
          expect(error.short_message).to eq('boom!')
          expect(error.field).to eq(:test)
        end
      end
    end
  end
end
