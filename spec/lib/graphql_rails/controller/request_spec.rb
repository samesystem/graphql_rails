# frozen_string_literal: true

require 'spec_helper'

module GraphqlRails
  RSpec.describe Controller::Request do
    subject(:request) { described_class.new(graphql_object, inputs, context) }

    let(:graphql_object) { double }
    let(:inputs) { { id: 1, firstName: 'John' } }
    let(:context) { double }

    describe '#lookahead' do
      subject(:lookahead) { request.lookahead }

      context 'when inputs do not contain "lookahead" key' do
        it { is_expected.to be_nil }
      end

      context 'when inputs contain "lookahead" key' do
        let(:inputs) { { lookahead: 'some_value' } }

        it 'returns value from inputs' do
          expect(lookahead).to eq 'some_value'
        end
      end
    end

    describe '#params' do
      subject(:params) { request.params }

      it 'returns inputs' do
        expect(params).to eq(inputs)
      end

      context 'when inputs contain "lookahead" key' do
        let(:inputs) { { lookahead: 'some_value' } }

        it 'returns inputs without lookahead key' do
          expect(params).to eq({})
        end
      end
    end
  end
end
