# frozen_string_literal: true

require 'spec_helper'

module GraphqlRails
  class Controller
    RSpec.describe ActionConfiguration do
      class DummyModel
        include GraphqlRails::Model
      end

      subject(:config) { described_class.new }

      describe '#return_type' do
        subject(:return_type) { config.return_type }

        context 'when custom type is set' do
          before do
            config.returns(DummyModel.name)
          end

          context 'when pagination is enabled' do
            before do
              config.paginated
            end

            it 'returns connection type' do
              expect(return_type).to eq DummyModel.graphql.connection_type
            end
          end

          context 'when pagination is not enabled' do
            it 'returns model graphql_type' do
              expect(return_type).to eq DummyModel.graphql.graphql_type
            end
          end
        end

        context 'when custom type is not set' do
          it { is_expected.to be_nil }
        end
      end

      describe '#paginated' do
        it 'sets pagination options' do
          expect { config.paginated(max_per_page: 1) }.to change(config, :pagination_options)
        end

        it 'sets pagination flag' do
          expect { config.paginated(max_per_page: 1) }.to change(config, :paginated?).to(true)
        end

        it 'permits "before", "after", "first" and "last" attribtues' do
          expect { config.paginated }.to change { config.attributes.keys }.to(%w[before after first last])
        end
      end

      describe '#paginated?' do
        context 'when paginated flat is not set' do
          it 'is not paginated' do
            expect(config).not_to be_paginated
          end
        end

        context 'when paginated flag is set' do
          it 'is paginated' do
            expect(config.paginated).to be_paginated
          end
        end
      end

      describe '#permit' do
        subject(:permitted_attribute) { config.attributes['name'].graphql_field_type }

        let(:permit_params) { { attribute_name => attribute_type } }
        let(:attribute_name) { :name }
        let(:attribute_type) { 'string' }

        before do
          config.permit(permit_params)
        end

        context 'when attribute name has bang at the end' do
          let(:attribute_name) { :name! }

          it 'sets attribute as required' do
            expect(permitted_attribute).to be_non_null
          end
        end

        context 'when attribute type has bang at the end' do
          let(:attribute_type) { 'string!' }

          it 'sets attribute as required' do
            expect(permitted_attribute).to be_non_null
          end
        end

        context 'when attribute name and type as no bang inside' do
          it 'sets attribute as optional' do
            expect(permitted_attribute).not_to be_non_null
          end
        end
      end

      describe '#description' do
        context 'when some value is set' do
          it 'changes config description value' do
            expect { config.description('O hi!') }.to change(config, :description).to('O hi!')
          end

          it 'returns config object' do
            expect(config.description('O hi!')).to eq config
          end
        end

        context 'when no value is given' do
          before { config.description('test') }

          it 'returns description value' do
            expect(config.description).to eq 'test'
          end
        end
      end

      describe '#returns' do
        it 'parses type correctly' do
          config.returns('[bool]!')

          expect(config.return_type)
            .to be_non_null
            .and be_list
        end
      end
    end
  end
end
