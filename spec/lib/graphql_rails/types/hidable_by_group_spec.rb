# frozen_string_literal: true

require 'spec_helper'

RSpec.describe GraphqlRails::Types::HidableByGroup do
  subject(:dummy_type) { dummy_type_class.new(groups: groups, hidden_in_groups: hidden_in_groups) }

  let(:dummy_class_parent) do
    Class.new do
      def visible?(_context)
        true
      end
    end
  end

  let(:dummy_type_class) do
    Class.new(dummy_class_parent) do
      include GraphqlRails::Types::HidableByGroup
    end
  end

  let(:groups) { [] }
  let(:hidden_in_groups) { [] }

  describe '#visible?' do
    subject(:visible?) { dummy_type.visible?(graphql_context) }

    let(:graphql_context) { { graphql_group: current_group } }
    let(:current_group) { 'dummy' }

    context 'when no groups are specified' do
      it { is_expected.to be true }
    end

    context 'when groups are specified' do
      context 'when current group is in groups' do
        let(:groups) { [current_group] }

        it { is_expected.to be true }
      end

      context 'when current group is not in groups' do
        let(:groups) { ['other_group'] }

        it { is_expected.to be false }
      end
    end

    context 'when hidden_in_groups are specified' do
      context 'when current group is in hidden_in_groups' do
        let(:hidden_in_groups) { [current_group] }

        it { is_expected.to be false }
      end

      context 'when current group is not in hidden_in_groups' do
        let(:hidden_in_groups) { ['other_group'] }

        it { is_expected.to be true }
      end
    end

    context 'when groups and hidden_in_groups are specified' do
      context 'when current group is in groups and hidden_in_groups' do
        let(:groups) { [current_group] }
        let(:hidden_in_groups) { [current_group] }

        it { is_expected.to be false }
      end

      context 'when current group is in groups and not in hidden_in_groups' do
        let(:groups) { [current_group] }
        let(:hidden_in_groups) { ['other_group'] }

        it { is_expected.to be true }
      end

      context 'when current group is not in groups and in hidden_in_groups' do
        let(:groups) { ['other_group'] }
        let(:hidden_in_groups) { [current_group] }

        it { is_expected.to be false }
      end

      context 'when current group is not in groups and not in hidden_in_groups' do
        let(:groups) { ['other_group'] }
        let(:hidden_in_groups) { ['other_group'] }

        it { is_expected.to be true }
      end
    end
  end
end
