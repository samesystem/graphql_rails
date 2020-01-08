# frozen_string_literal: true

require 'spec_helper'

module GraphqlRails
  RSpec.describe Controller::Configuration do
    subject(:configuration) { described_class.new(nil) }

    let(:define_action_default) { nil }

    let(:define_actions) do
      configuration.action(:some_method).permit(:id)
      configuration.action(:some_other_method).permit(:id, :name)
    end

    before do
      define_action_default
      define_actions
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

      context 'when action_default was defined' do
        let(:define_action_default) { configuration.action_default.permit(default: :string!) }

        it 'inherits attributes from action_default' do
          expect(configuration.action(:some_method).attributes.keys).to match_array(%w[default id])
        end

        it 'does not modify default action itself' do
          expect(configuration.action_default.attributes.keys).to match_array(%w[default])
        end
      end

      context 'when options was used' do
        let(:define_actions) do
          configuration.action(:some_method).options(input_format: :original).permit(:id)
          configuration.action(:some_other_method).permit(:id, :name)
        end

        it 'sets options only for given action', :aggregate_failures do
          expect(configuration.action(:some_method).options).to eq(input_format: :original)
          expect(configuration.action(:some_other_method).options).to eq({})
        end
      end

      context 'when pagination options was set' do
        let(:define_actions) do
          configuration.action(:some_method).paginated(max_page_size: 200).permit(:id)
          configuration.action(:some_other_method).permit(:id, :name)
        end

        it 'sets options only for given action', :aggregate_failures do
          expect(configuration.action(:some_method).pagination_options).to eq(max_page_size: 200)
          expect(configuration.action(:some_other_method).pagination_options).to be_nil
        end
      end
    end

    describe '#action_config' do
      subject(:action_config) { configuration.action_config(action_name) }

      let(:action_name) { :some_method }


      context 'when action was defined before' do
        it 'returns action config' do
          expect(action_config).to be_a(Controller::ActionConfiguration)
        end
      end

      context 'when action was not defined before' do
        let(:action_name) { :some_non_existing_method }

        it 'raises error' do
          expect { action_config }.to raise_error(Controller::Configuration::InvalidActionConfiguration)
        end
      end
    end

    describe '#model' do
      it 'sets model for default action' do
        configuration.model('String')
        expect(configuration.action_default.model).to eq 'String'
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
