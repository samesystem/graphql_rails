# frozen_string_literal: true

require 'spec_helper'

module GraphqlRails
  module Attributes
    RSpec.describe Attribute do
      subject(:attribute) { described_class.new(name).with(type: type, options: options) }

      let(:type) { 'String!' }
      let(:name) { 'full_name' }
      let(:options) { {} }

      describe '#property' do
        it 'sets property correctly' do
          expect { attribute.property(:new_property) }.to change(attribute, :property).to('new_property')
        end
      end

      describe '#options' do
        it 'sets options correctly' do
          expect { attribute.options(new_option: true) }.to change(attribute, :options).to(new_option: true)
        end
      end

      describe '#required' do
        let(:type) { 'String' }

        it 'marks attribute as required' do
          expect { attribute.required }.to change(attribute, :required?).to(true)
        end
      end

      describe '#optional' do
        it 'marks attribute as not required' do
          expect { attribute.optional }.to change(attribute, :required?).to(false)
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

      describe '#type_name' do
        it 'returns stringified type name' do
          expect(attribute.type_name).to eq 'String!'
        end
      end

      describe '#deprecated' do
        it 'sets deprecation_reason' do
          expect { attribute.deprecated('I do not like it') }
            .to change(attribute, :deprecation_reason).to('I do not like it')
        end
      end

      describe '#field_args' do
        subject(:field_args) { attribute.field_args }

        context 'when type is not set' do
          let(:type) { nil }

          context 'when name ends with question mark (?)' do
            let(:name) { :admin? }

            it 'returns boolean type' do
              expect(field_args[1]).to eq GraphQL::Types::Boolean
            end
          end

          context 'when name ends with "id"' do
            let(:name) { :id }

            it 'returns id type' do
              expect(field_args[1]).to eq GraphQL::Types::ID
            end
          end
        end

        context 'when attribute is GraphQL::Schema::NonNull instance' do
          let(:type) { GraphQL::Schema::NonNull.new(GraphQL::Types::String) }

          it 'builds required type' do
            expect(field_args[1]).to eq(GraphQL::Types::String)
          end
        end

        context 'when attribute is array' do
          let(:type) { '[Int!]!' }

          context 'when array is required' do
            let(:type) { '[Int]!' }

            it 'builds optional list type field' do
              expect(field_args[1]).to eq([GraphQL::Types::Int, null: true])
            end
          end

          context 'when inner type of array is required' do
            let(:type) { '[Int!]' }

            it 'builds required inner array type' do
              expect(field_args[1]).to eq([GraphQL::Types::Int])
            end
          end

          context 'when array and its inner type is required' do
            it 'builds required inner array type' do
              expect(field_args[1]).to eq([GraphQL::Types::Int])
            end
          end

          context 'when array and its inner type are optional' do
            let(:type) { '[Int]' }

            it 'builds optional list type field' do
              expect(field_args[1]).to eq([GraphQL::Types::Int, null: true])
            end
          end
        end
      end

      describe '#field_options' do
        subject(:field_options) { attribute.field_options }

        context 'when attribute is GraphQL::Schema::NonNull instance' do
          let(:type) { GraphQL::Schema::NonNull.new(GraphQL::Types::String) }

          it 'builds required field' do
            expect(field_options).to include(null: false)
          end
        end

        context 'when type is not set' do
          let(:type) { nil }

          context 'when attribute name ends without bang mark (!)' do
            it 'builds optional field' do
              expect(field_options).to include(null: true)
            end
          end

          context 'when attribute name ends with bang mark (!)' do
            let(:name) { :full_name! }

            it 'builds required field' do
              expect(field_options).to include(null: false)
            end
          end
        end

        context 'when attribute is required' do
          it 'builds required field' do
            expect(field_options).to include(null: false)
          end
        end

        context 'when attribute name format options are passed' do
          let(:options) { { attribute_name_format: :original } }

          it 'forwards disables camelize' do
            expect(field_options).to include(camelize: false)
          end
        end

        context 'when attribute name format options are not passed' do
          it 'ignores keeps camelize active' do
            expect(field_options).to include(camelize: true)
          end
        end

        context 'when attribute is optional' do
          let(:type) { 'String' }

          it 'builds optional field' do
            expect(field_options).to include(null: true)
          end
        end

        context 'when attribute is array' do
          let(:type) { '[Int!]!' }

          context 'when array is required' do
            let(:type) { '[Int]!' }

            it 'builds required outer field' do
              expect(field_options).to include(null: false)
            end
          end

          context 'when inner type of array is required' do
            let(:type) { '[Int!]' }

            it 'builds optional outer field' do
              expect(field_options).to include(null: true)
            end
          end

          context 'when array and its inner type is required' do
            it 'builds required outer field' do
              expect(field_options).to include(null: false)
            end
          end

          context 'when array and its inner type are optional' do
            let(:type) { '[Int]' }

            it 'builds optional outer field' do
              expect(field_options).to include(null: true)
            end
          end
        end

        context 'when attribute does not belong to any groups' do
          it 'builds field with empty groups' do
            expect(field_options).to include(groups: [])
          end
        end

        context 'when attribute belongs to a group' do
          before do
            attribute.group(:some_group)
          end

          it 'builds field with a given group' do
            expect(field_options).to include(groups: %w[some_group])
          end
        end

        context 'when attribute is hidden in a group' do
          before do
            attribute.hidden_in_groups(:some_group)
          end

          it 'builds field with a given group' do
            expect(field_options).to include(hidden_in_groups: %w[some_group])
          end
        end

        context 'when deprecation reason is set' do
          before do
            attribute.deprecated('I do not like it')
          end

          it 'returns deprecation reason' do
            expect(field_options).to include(deprecation_reason: 'I do not like it')
          end
        end

        context 'when extras are set' do
          before do
            attribute.extras([:lookahead])
          end

          it 'returns extras' do
            expect(field_options).to include(extras: [:lookahead])
          end
        end
      end
    end
  end
end
