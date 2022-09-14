# frozen_string_literal: true

require 'spec_helper'

module GraphqlRails
  RSpec.describe SystemError do
    subject(:system_error) { described_class.new(error) }

    let(:error) { Error.new }

    describe '#backtrace' do
      subject(:backtrace) { system_error.backtrace }

      it 'has same backtrace as original error' do
        expect(backtrace).to eq(error.backtrace)
      end
    end

    describe '#original_error' do
      subject(:original_error) { system_error.original_error }

      it 'points to original error' do
        expect(original_error).to eq(error)
      end
    end
  end
end
