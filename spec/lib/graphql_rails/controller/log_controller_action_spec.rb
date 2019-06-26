# frozen_string_literal: true

require 'spec_helper'
require 'rails'

module GraphqlRails
  class Controller
    RSpec.describe LogControllerAction do
      subject(:log_controller_action) do
        described_class.new(
          controller_name: 'UsersController',
          action_name: 'create',
          graphql_request: double('GraphqlRequest', errors: []), # rubocop:disable RSpec/VerifiedDoubles
          params: params
        )
      end

      let(:params) { { email: 'john@example.com', password: 'secret123' } }

      # rubocop:disable RSpec/InstanceVariable
      describe '#call' do
        subject(:call) { log_controller_action.call {} }

        let(:last_event) { @last_process_event }

        before do
          allow(Rails).to receive(:application).and_return(OpenStruct.new(config: OpenStruct.new))

          ActiveSupport::Notifications.subscribe(described_class::START_PROCESSING_KEY) do |*_, payload|
            @last_start_processing_event = payload
          end

          ActiveSupport::Notifications.subscribe(described_class::PROCESS_ACTION_KEY) do |*_, payload|
            @last_process_event = payload
          end
        end

        it 'logs events' do
          expect { call }
            .to change { @last_process_event }
            .and change { @last_start_processing_event }
        end

        context 'when filter options are given' do
          before do
            Rails.configuration.filter_parameters = [:password]
          end

          it 'filters sensitive params' do
            call
            expect(last_event[:params]).to include(password: '[FILTERED]')
          end
        end

        context 'when error happens while processing action' do
          subject(:call) do
            log_controller_action.call do
              raise GraphqlRails::ExecutionError, 'Stop! Hammer time!'
            end
          end

          it 'logs events', :aggregate_failures do
            expect { call }
              .to raise_error('Stop! Hammer time!')
              .and change { @last_process_event }
          end
        end
      end
      # rubocop:enable RSpec/InstanceVariable
    end
  end
end
