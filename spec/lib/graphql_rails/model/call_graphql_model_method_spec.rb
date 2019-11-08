# frozen_string_literal: true

require 'spec_helper'

module GraphqlRails
  module Model
    RSpec.describe CallGraphqlModelMethod do
      subject(:call) do
        described_class.call(
          model: model_instance,
          attribute_config: attribute_config,
          method_keyword_arguments: method_keyword_arguments,
          graphql_context: graphql_context
        )
      end

      let(:model_instance) { model.new }

      let(:model) do
        Class.new do
          include GraphqlRails::Model

          graphql do |c|
            c.description 'Used for test purposes'
            c.attribute :trigger_context
            c.attribute :trigger_kwargs, permit: { arg1: :string }
            c.attribute :trigger_paginated_kwargs, paginated: true, permit: { arg1: :string }
          end

          def self.name
            'DummyModel'
          end

          def trigger_context
            graphql_context[:value]
          end

          def trigger_kwargs(arg1: 'default value')
            arg1
          end

          def trigger_paginated_kwargs(**kwargs)
            kwargs
          end
        end
      end

      let(:attribute_config) { model.graphql.attributes['trigger_context'] }
      let(:graphql_context) { { value: 'this is context' } }
      let(:method_keyword_arguments) { {} }

      describe '#call' do
        context 'when method uses graphql_context' do
          it 'receives correct context' do
            expect(call).to eq 'this is context'
          end
        end

        context 'when model is not GraphqlRails model' do
          let(:attribute_config) { model.graphql.attributes['trigger_kwargs'] }

          let(:model_instance) { non_graphql_model.new }
          let(:method_keyword_arguments) { { arg1: 'yes' } }

          let(:non_graphql_model) do
            Class.new do
              def self.name
                'DummyModel2'
              end

              def trigger_kwargs(**kwargs)
                kwargs
              end
            end
          end

          it 'works correctly' do
            expect(call).to eq(arg1: 'yes')
          end
        end

        context 'when method accepts keywords' do
          let(:attribute_config) { model.graphql.attributes['trigger_kwargs'] }

          context 'when keywords are given' do
            let(:method_keyword_arguments) { { arg1: 'this is arg1' } }

            context 'when method result is not paginated' do
              it 'receives all given arguments' do
                expect(call).to eq 'this is arg1'
              end
            end

            context 'when method result is paginated' do
              let(:attribute_config) { model.graphql.attributes['trigger_paginated_kwargs'] }
              let(:method_keyword_arguments) do
                {
                  first: 10,
                  after: '5',
                  before: '9',
                  last: 5,
                  arg1: 'this is arg1'
                }
              end

              it 'skips pagination arguments' do
                expect(call).to eq(arg1: 'this is arg1')
              end
            end
          end

          context 'when keywords are not given' do
            it 'uses default keyword values' do
              expect(call).to eq 'default value'
            end
          end
        end
      end
    end
  end
end
