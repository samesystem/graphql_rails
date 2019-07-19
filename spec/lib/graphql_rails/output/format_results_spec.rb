# frozen_string_literal: true

require 'spec_helper'
require 'graphql/relay'

module GraphqlRails
  class Controller
    RSpec.describe GraphqlRails::Output::FormatResults do
      subject(:formatter) do
        described_class.new(
          original_result,
          input_config: action_config,
          graphql_context: nil,
          params: {}
        )
      end

      let(:original_result) { 'Hello!' }
      let(:action_config) { instance_double(ActionConfiguration, paginated?: is_paginated, pagination_options: {}) }
      let(:is_paginated) { false }

      describe '#call' do
        subject(:call) { formatter.call }

        context 'when pagination is off' do
          it 'returns original result' do
            expect(call).to eq original_result
          end
        end

        context 'when pagination is on' do
          let(:is_paginated) { true }
          let(:original_result) { [] }

          context 'when result is nil' do
            let(:original_result) { nil }

            it { is_expected.to be_nil }
          end

          context 'when result is not nil' do
            it 'returns Graphql object' do
              expect(call).to be_a(GraphQL::Relay::BaseConnection)
            end
          end
        end
      end
    end
  end
end
