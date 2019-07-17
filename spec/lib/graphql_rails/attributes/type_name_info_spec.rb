# frozen_string_literal: true

require 'spec_helper'

module GraphqlRails
  module Attributes
    RSpec.describe TypeNameInfo do
      subject(:type_name_info) { described_class.new(type_name) }

      let(:type_name) { 'Dummy' }

      describe '#nullable_inner_name' do
        subject(:nullable_inner_name) { type_name_info.nullable_inner_name }

        context 'when type name is GraphQL array' do
          let(:type_name) { '[Dummy!]!' }

          it 'returns non-array name without non-null requirement' do
            expect(nullable_inner_name).to eq('Dummy')
          end
        end

        context 'when name is already non-array and nullable' do
          it 'returns original name' do
            expect(nullable_inner_name).to eq type_name
          end
        end

        context 'when name contains non-graphql symbols' do
          let(:type_name) { '[::Graphql::Dummy!]!' }

          it 'keeps non graphql symbols' do
            expect(nullable_inner_name).to eq '::Graphql::Dummy'
          end
        end
      end

      describe '#inner_name' do
        subject(:inner_name) { type_name_info.inner_name }

        context 'when type name is GraphQL array with non-null type' do
          let(:type_name) { '[Dummy!]!' }

          it 'returns non-array name with non-null requirement' do
            expect(inner_name).to eq('Dummy!')
          end
        end

        context 'when type name is GraphQL array with nullable type' do
          let(:type_name) { '[Dummy]!' }

          it 'returns non-array name with non-null requirement' do
            expect(inner_name).to eq('Dummy')
          end
        end

        context 'when name is non-array and nullable' do
          it 'returns original name' do
            expect(inner_name).to eq type_name
          end
        end

        context 'when name is non-array and non-null' do
          let(:type_name) { 'Dummy!' }

          it 'returns original name' do
            expect(inner_name).to eq type_name
          end
        end
      end

      describe '#required_inner_type?' do
        context 'when type is array with non-null inner type' do
          let(:type_name) { '[Dummy!]!' }

          it { is_expected.to be_required_inner_type }
        end

        context 'when type is array with nullable inner type' do
          let(:type_name) { '[Dummy]!' }

          it { is_expected.not_to be_required_inner_type }
        end

        context 'when type is non-null' do
          let(:type_name) { 'Dummy!' }

          it { is_expected.to be_required_inner_type }
        end

        context 'when type is nullable' do
          it { is_expected.not_to be_required_inner_type }
        end
      end

      describe '#list?' do
        context 'when type is array' do
          let(:type_name) { '[Dummy]!' }

          it { is_expected.to be_list }
        end

        context 'when type is not array' do
          let(:type_name) { 'Dummy!' }

          it { is_expected.not_to be_list }
        end
      end

      describe '#required?' do
        context 'when type is non-null array with non-null inner type' do
          let(:type_name) { '[Dummy!]!' }

          it { is_expected.to be_required }
        end

        context 'when type is non-null array with nullable inner type' do
          let(:type_name) { '[Dummy]!' }

          it { is_expected.to be_required }
        end

        context 'when type is nullable array with nullable inner type' do
          let(:type_name) { '[Dummy]' }

          it { is_expected.not_to be_required }
        end

        context 'when type is nullable array with non-null inner type' do
          let(:type_name) { '[Dummy!]' }

          it { is_expected.not_to be_required }
        end

        context 'when type is non-null' do
          let(:type_name) { 'Dummy!' }

          it { is_expected.to be_required }
        end

        context 'when type is nullable' do
          it { is_expected.not_to be_required }
        end
      end

      describe '#required_list?' do
        context 'when type is non-null array with non-null inner type' do
          let(:type_name) { '[Dummy!]!' }

          it { is_expected.to be_required_list }
        end

        context 'when type is non-null array with nullable inner type' do
          let(:type_name) { '[Dummy]!' }

          it { is_expected.to be_required_list }
        end

        context 'when type is nullable array with nullable inner type' do
          let(:type_name) { '[Dummy]' }

          it { is_expected.not_to be_required_list }
        end

        context 'when type is nullable array with non-null inner type' do
          let(:type_name) { '[Dummy!]' }

          it { is_expected.not_to be_required_list }
        end

        context 'when type is not array' do
          let(:type_name) { 'Dummy!' }

          it { is_expected.not_to be_required_list }
        end
      end
    end
  end
end
