# frozen_string_literal: true

require 'spec_helper'

module GraphqlRails
  module Attributes
    RSpec.describe Attribute do
      subject(:attribute) { described_class.new(name, type) }

      let(:type) { 'String!' }
      let(:name) { 'full_name' }

      describe '#property' do
        it 'sets property correctly' do
          expect { attribute.property(:new_property) }.to change(attribute, :property).to('new_property')
        end
      end

      describe '#description' do
        it 'sets description correctly' do
          expect { attribute.description('new') }.to change(attribute, :description).to('new')
        end
      end

      describe '#type' do
        it 'sets type correctly' do
          expect { attribute.type(:int!) }.to change(attribute, :type).to(:int!)
        end
      end

      describe '#field_args' do
        subject(:field_args) { attribute.field_args }

        context 'when type is not set' do
          let(:type) { nil }

          context 'when attribute name ends without bang mark (!)' do
            it 'builds optional field' do
              expect(field_args.last).to include(null: true)
            end
          end

          context 'when attribute name ends with bang mark (!)' do
            let(:name) { :full_name! }

            it 'builds required field' do
              expect(field_args.last).to include(null: false)
            end
          end

          context 'when name ends with question mark (?)' do
            let(:name) { :admin? }

            it 'returns boolean type' do
              expect(field_args[1]).to eq GraphQL::BOOLEAN_TYPE
            end
          end

          context 'when name ends with "id"' do
            let(:name) { :id }

            it 'returns id type' do
              expect(field_args[1]).to eq GraphQL::ID_TYPE
            end
          end
        end

        context 'when attribute is required' do
          it 'builds required field' do
            expect(field_args.last).to include(null: false)
          end
        end

        context 'when attribute is optional' do
          let(:type) { 'String' }

          it 'builds optional field' do
            expect(field_args.last).to include(null: true)
          end
        end

        context 'when attribute is array' do
          let(:type) { '[Int!]!' }

          context 'when array is required' do
            let(:type) { '[Int]!' }

            it 'builds required outher field' do
              expect(field_args.last).to include(null: false)
            end

            it 'builds optional list type field' do
              expect(field_args[1]).to eq([GraphQL::INT_TYPE, null: true])
            end
          end

          context 'when inner type of array is required' do
            let(:type) { '[Int!]' }

            it 'builds optional outher field' do
              expect(field_args.last).to include(null: true)
            end

            it 'builds required inner array type' do
              expect(field_args[1]).to eq([GraphQL::INT_TYPE])
            end
          end

          context 'when array and its inner type is required' do
            it 'builds required outher field' do
              expect(field_args.last).to include(null: false)
            end

            it 'builds required inner array type' do
              expect(field_args[1]).to eq([GraphQL::INT_TYPE])
            end
          end

          context 'when array and its inner type are optional' do
            let(:type) { '[Int]' }

            it 'builds optional outher field' do
              expect(field_args.last).to include(null: true)
            end

            it 'builds optional list type field' do
              expect(field_args[1]).to eq([GraphQL::INT_TYPE, null: true])
            end
          end
        end
      end
    end
  end
end
