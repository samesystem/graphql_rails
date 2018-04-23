# frozen_string_literal: true

require 'spec_helper'

module Graphiti
  RSpec.describe Controller do
    class DummyController < Graphiti::Controller
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

    subject(:controller) { DummyController.new(request) }

    let(:request) { Graphiti::Controller::Request.new(graphql_object, inputs, context) }
    let(:graphql_object) { nil }
    let(:inputs) { {} }
    let(:context) { instance_double(GraphQL::Query::Context::FieldResolutionContext) }

    describe '.call' do
      subject(:call) { controller.call(controller_action) }

      let(:controller_action) { :respond_with_render }

      context 'when render was used' do
        context 'when errors was rendered' do
          let(:controller_action) { :respond_with_rendered_errors }

          before do
            allow(context).to receive(:add_error)
          end

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
  end
end
