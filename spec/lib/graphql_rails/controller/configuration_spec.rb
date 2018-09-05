# frozen_string_literal: true

require 'spec_helper'

module GraphqlRails
  RSpec.describe Controller::Configuration do
    class DummyController < Controller
      action(:some_method).permit(:id)
      def some_method; end

      action(:some_other_method).permit(:id, :name)
      def some_other_method; end
    end

    subject(:configuration) { DummyController.controller_configuration }

    let(:controller) { DummyController }

    describe '#action' do
      it 'returns hash with specified acceptable arguments' do
        expect(configuration.action(:some_method).attributes.keys).to match_array(%w[id])
      end
    end

    describe '#add_before_action' do
      it 'adds filter' do
        expect { configuration.add_before_action(:filter) }
          .to change { configuration.before_actions_for(:any).count }.by(1)
      end

      context 'when adding same filter multiple times' do
        before { configuration.add_before_action(:filter) }

        it 'replaces existing before action filter' do
          expect { configuration.add_before_action(:filter) }
            .not_to change { configuration.before_actions_for(:any).count }
        end

        it 'applies options from last assigned filter' do
          expect { configuration.add_before_action(:filter, except: :action) }
            .to change { configuration.before_actions_for(:action).count }.by(-1)
        end
      end
    end
  end
end
