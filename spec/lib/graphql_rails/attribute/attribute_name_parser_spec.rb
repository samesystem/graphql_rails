# frozen_string_literal: true

require 'spec_helper'

module GraphqlRails
  class Attribute
    RSpec.describe AttributeNameParser do
      subject(:parser) { described_class.new(name, options: options) }

      let(:name) { 'name' }
      let(:options) { {} }

      describe '#field_name' do
        subject(:field_name) { parser.field_name }

        context 'when name contains multiple words' do
          let(:name) { 'full_name' }

          context 'without options' do
            it 'camelizes name' do
              expect(field_name).to eq('fullName')
            end
          end

          context 'with original format option' do
            let(:options) { { input_format: :original } }

            it 'keeps original format' do
              expect(field_name).to eq(name)
            end
          end
        end

        context 'when name ends with bang mark' do
          let(:name) { :awesome! }

          it 'removes bang mark' do
            expect(field_name).to eq 'awesome'
          end
        end

        context 'when name ends with question mark (?)' do
          let(:name) { :almighty_admin? }

          it 'adds "is" prefix and removes question mark' do
            expect(field_name).to eq 'isAlmightyAdmin'
          end
        end
      end

      describe '#graphql_type' do
        subject(:graphql_type) { parser.graphql_type }

        context 'when name ends with question mark (?)' do
          let(:name) { :admin? }

          it 'returns boolean type' do
            expect(graphql_type).to eq GraphQL::BOOLEAN_TYPE
          end
        end

        context 'when name ends with "id"' do
          let(:name) { :id }

          it 'returns id type' do
            expect(graphql_type).to eq GraphQL::ID_TYPE
          end
        end

        context 'when name does not end with special suffix' do
          it 'returns String type' do
            expect(graphql_type).to eq GraphQL::STRING_TYPE
          end
        end
      end

      describe '#required?' do
        context 'when name does not have bang at the end' do
          it { is_expected.not_to be_required }
        end

        context 'when name has bang at the end' do
          let(:name) { 'name!' }

          it { is_expected.to be_required }
        end
      end
    end
  end
end
