# frozen_string_literal: true

require 'spec_helper'

module GraphqlRails
  RSpec.describe Controller::Configuration do
    subject(:configuration) { described_class.new }

    before do
      configuration.action(:some_method).permit(:id)
      configuration.action(:some_other_method).permit(:id, :name)
    end

    describe '#dup' do
      subject(:duplicate) { configuration.dup }

      context 'when original config has hooks' do
        before do
          configuration.add_action_hook(:after, :action1)
        end

        context 'when duplicate has additional hooks' do
          before do
            duplicate.add_action_hook(:after, :action2)
          end

          it 'does not change original config hooks' do
            expect(configuration.action_hooks_for(:after, :any).map(&:name)).to eq %i[action1]
          end

          it 'adds additioanl hooks to duplicate only' do
            expect(duplicate.action_hooks_for(:after, :any).map(&:name)).to eq %i[action1 action2]
          end
        end
      end

      context 'when original config has action config' do
        before do
          configuration.action(:show).permit(id: 'ID!')
        end

        context 'when duplicate has different action config' do
          before do
            duplicate.action(:show).permit(name: 'String!')
          end

          it 'does not modify original action config' do
            expect(configuration.action(:show).attributes.keys).to eq %w[id]
          end

          it 'adds additional details to duplicated config only' do
            expect(duplicate.action(:show).attributes.keys).to eq %w[id name]
          end
        end
      end
    end

    describe '#action' do
      it 'returns hash with specified acceptable arguments' do
        expect(configuration.action(:some_method).attributes.keys).to match_array(%w[id])
      end
    end

    describe '#add_action_hook' do
      it 'adds hook' do
        expect { configuration.add_action_hook(:after, :filter) }
          .to change { configuration.action_hooks_for(:after, :any).count }.by(1)
      end

      context 'when adding same hook multiple times' do
        before { configuration.add_action_hook(:before, :filter) }

        it 'replaces existing action hook' do
          expect { configuration.add_action_hook(:before, :filter) }
            .not_to change { configuration.action_hooks_for(:before, :any).count }
        end

        it 'applies options from last assigned hook' do
          expect { configuration.add_action_hook(:before, :filter, except: :action) }
            .to change { configuration.action_hooks_for(:before, :action).count }.by(-1)
        end
      end
    end
  end
end
