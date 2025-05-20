# frozen_string_literal: true

require 'spec_helper'

module GraphqlRails
  module Model
    RSpec.describe DirectFieldResolver do
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
            c.attribute :simple_property
            c.attribute :context_aware_property
            c.attribute :paginated_property, paginated: true
            c.attribute :with_args_property, permit: { arg1: :string }
          end

          def self.name
            'DummyModel'
          end

          def simple_property
            'simple value'
          end

          def context_aware_property
            graphql_context[:value]
          end

          def paginated_property
            'paginated value'
          end

          def with_args_property(arg1: 'default')
            arg1
          end

          def with_graphql_context(context)
            @graphql_context = context
            result = yield
            @graphql_context = nil
            result
          end

          private

          def graphql_context
            @graphql_context || {}
          end
        end
      end

      let(:attribute_config) { model.graphql.attributes['simple_property'] }
      let(:graphql_context) { { value: 'context value' } }
      let(:method_keyword_arguments) { {} }

      describe '#call' do
        context 'when method is simple with no arguments and not paginated' do
          it 'uses simple_resolver' do
            expect(call).to eq 'simple value'
          end

          it 'does not call CallGraphqlModelMethod' do
            allow(CallGraphqlModelMethod).to receive(:call)
            call
            expect(CallGraphqlModelMethod).not_to have_received(:call)
          end
        end

        context 'when method needs graphql context' do
          let(:attribute_config) { model.graphql.attributes['context_aware_property'] }

          it 'passes the context correctly' do
            expect(call).to eq 'context value'
          end
        end

        context 'when method is paginated' do
          let(:attribute_config) { model.graphql.attributes['paginated_property'] }

          before do
            allow(CallGraphqlModelMethod).to receive(:call).and_call_original

            call
          end

          it 'falls back to CallGraphqlModelMethod and works correctly' do
            expect(CallGraphqlModelMethod).to have_received(:call).with(
              model: model_instance, attribute_config: attribute_config,
              method_keyword_arguments: method_keyword_arguments, graphql_context: graphql_context
            )
          end
        end

        context 'when method has arguments' do
          let(:attribute_config) { model.graphql.attributes['with_args_property'] }
          let(:method_keyword_arguments) { { arg1: 'custom value' } }

          before do
            allow(CallGraphqlModelMethod).to receive(:call).and_call_original

            call
          end

          it 'falls back to CallGraphqlModelMethod and passes arguments correctly' do
            expect(CallGraphqlModelMethod).to have_received(:call).with(
              model: model_instance, attribute_config: attribute_config,
              method_keyword_arguments: method_keyword_arguments, graphql_context: graphql_context
            )
          end
        end
      end
    end
  end
end
