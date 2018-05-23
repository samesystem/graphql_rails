# frozen_string_literal: true

require 'spec_helper'

module GraphqlRails
  RSpec.describe Controller do
    DummyUserInput = GraphQL::InputObjectType.define {}

    class DummyInputsController < GraphqlRails::Controller
      action(:create).permit(:id, user!: DummyUserInput)
    end

    class DummyBeforeActionsController < GraphqlRails::Controller
      before_action :action1
      before_action :action2
      before_action :action3

      def action1; end

      def action2; end

      def action3; end
    end

    class DummyCallController < GraphqlRails::Controller
      def respond_with_render
        render 'Hello from render'
        'This should not be returned'
      end

      def respond_with_rendered_errors
        render error: 'bam!'
        'This should not be returned'
      end

      def respond_with_raised_error
        raise StandardError, 'ups!'
      end

      def respond_without_render
        'Hello without render!'
      end
    end

    subject(:controller) { DummyCallController.new(request) }

    let(:request) { Controller::Request.new(graphql_object, inputs, context) }
    let(:graphql_object) { nil }
    let(:inputs) { {} }
    let(:context) { instance_double(GraphQL::Query::Context::FieldResolutionContext) }

    describe '.action' do
      subject(:action) { DummyInputsController.controller_configuration.action(:create) }

      it 'saves all input fields' do
        expect(action.attributes.keys).to match_array %w[id user]
      end
    end

    describe '#call' do
      subject(:call) { controller.call(controller_action) }

      let(:controller_action) { :respond_with_render }

      before do
        allow(context).to receive(:add_error)
      end

      context 'when before actions are set' do
        let(:controller) { DummyBeforeActionsController.new(request) }

        context 'when before_action raises error' do
          let(:error) { StandardError.new('Boom!') }

          before do
            allow(controller).to receive(:action2).and_raise(error)
          end

          it 'does not raise error' do
            expect { call }.not_to raise_error
          end

          it 'adds first error in to context' do
            call
            expect(context).to have_received(:add_error).once
          end

          it 'stops executing before actions after first failure' do
            allow(controller).to receive(:action3)
            call
            expect(controller).not_to have_received(:action3)
          end
        end
      end

      context 'when render was used' do
        context 'when errors was rendered' do
          let(:controller_action) { :respond_with_rendered_errors }

          it 'returns result as nil' do
            expect(call).to be_nil
          end

          it 'adds errors' do
            call
            expect(context).to have_received(:add_error).with(ExecutionError.new('bam!'))
          end
        end

        context 'when result was rendered' do
          it 'returns rendered result' do
            expect(call).to eq 'Hello from render'
          end
        end

        context 'when error was raised' do
          let(:controller_action) { :respond_with_raised_error }

          before do
            allow(context).to receive(:add_error)
          end

          it 'adds error' do
            call
            expect(context).to have_received(:add_error).with(ExecutionError.new('ups!'))
          end

          it 'returns nil' do
            expect(call).to be_nil
          end
        end

        context 'when rendering was not triggered' do
          let(:controller_action) { :respond_without_render }

          it 'render last value' do
            expect(call).to eq 'Hello without render!'
          end
        end
      end
    end

    describe '#params' do
      it 'retuns hash with indifferent access' do
        expect(controller.send(:params)).to be_a(HashWithIndifferentAccess)
      end
    end
  end
end
