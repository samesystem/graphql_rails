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
  end
end
