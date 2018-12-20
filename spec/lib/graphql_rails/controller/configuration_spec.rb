# frozen_string_literal: true

require 'spec_helper'

module GraphqlRails
  RSpec.describe Controller::Configuration do
    subject(:configuration) { described_class.new }

    before do
      configuration.action(:some_method).permit(:id)
      configuration.action(:some_other_method).permit(:id, :name)
    end

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

        it 'replaces existing action filter' do
          expect { configuration.add_before_action(:filter) }
            .not_to change { configuration.before_actions_for(:any).count }
        end

        it 'applies options from last assigned filter' do
          expect { configuration.add_before_action(:filter, except: :action) }
            .to change { configuration.before_actions_for(:action).count }.by(-1)
        end
      end
    end

    describe '#add_after_action' do
      it 'adds filter' do
        expect { configuration.add_after_action(:filter) }
          .to change { configuration.after_actions_for(:any).count }.by(1)
      end

      context 'when adding same filter multiple times' do
        before { configuration.add_after_action(:filter) }

        it 'replaces existing action filter' do
          expect { configuration.add_after_action(:filter) }
            .not_to change { configuration.after_actions_for(:any).count }
        end

        it 'applies options from last assigned filter' do
          expect { configuration.add_after_action(:filter, except: :action) }
            .to change { configuration.after_actions_for(:action).count }.by(-1)
        end
      end
    end

    describe '#add_around_action' do
      it 'adds filter' do
        expect { configuration.add_around_action(:filter) }
          .to change { configuration.around_actions_for(:any).count }.by(1)
      end

      context 'when adding same filter multiple times' do
        before { configuration.add_around_action(:filter) }

        it 'replaces existing action filter' do
          expect { configuration.add_around_action(:filter) }
            .not_to change { configuration.around_actions_for(:any).count }
        end

        it 'applies options from last assigned filter' do
          expect { configuration.add_around_action(:filter, except: :action) }
            .to change { configuration.around_actions_for(:action).count }.by(-1)
        end
      end
    end
  end
end
