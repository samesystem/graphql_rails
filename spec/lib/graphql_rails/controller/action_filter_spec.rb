# frozen_string_literal: true

require 'spec_helper'

module GraphqlRails
  class Controller
    RSpec.describe ActionFilter do
      subject(:filter) { described_class.new(action_name, only: only_actions, except: except_actions) }

      let(:only_actions) { [] }
      let(:except_actions) { [] }
      let(:action_name) { :some_action }

      describe '#applicable_for?' do
        context 'when `only` and `except` is not specified' do
          it { is_expected.to be_applicable_for(:any_action) }
        end

        context 'when `only` is specified' do
          let(:only_actions) { action_name }

          context 'when action name is included in `only` option as array' do
            let(:only_actions) { [action_name] }

            it { is_expected.to be_applicable_for(action_name) }
          end

          context 'when action name is included in `only` option' do
            it { is_expected.to be_applicable_for(action_name) }
          end

          context 'when action name is not included in `only` option' do
            it { is_expected.not_to be_applicable_for(:does_not_exist) }
          end
        end

        context 'when `except` is specified' do
          let(:except_actions) { action_name }

          context 'when action name is not included in `except` option' do
            it { is_expected.to be_applicable_for(:does_not_exist) }
          end

          context 'when action name is included in `except` option as array' do
            let(:except_actions) { [action_name] }

            it { is_expected.not_to be_applicable_for(action_name) }
          end

          context 'when action name is included in `except` option' do
            it { is_expected.not_to be_applicable_for(action_name) }
          end
        end
      end
    end
  end
end
