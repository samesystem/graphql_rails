# frozen_string_literal: true

require 'spec_helper'

module GraphqlRails
  class Controller
    RSpec.describe ActionHooksRunner do
      shared_context 'with action hooks' do |type|
        before do
          [:"#{type}_action1", :"#{type}_action2"].each do |action_hook_name|
            controller_configuration.add_action_hook(type, action_hook_name)
            allow(controller).to receive(action_hook_name)
          end
        end
      end

      shared_context 'with around action hooks' do
        before do
          %i[around_action1 around_action2].each do |action_hook_name|
            controller_configuration.add_action_hook(:around, action_hook_name)
            allow(controller).to receive(action_hook_name).and_yield
          end
        end
      end

      subject(:runner) do
        described_class.new(
          action_name: action_name,
          controller: controller,
          graphql_request: graphql_request
        )
      end

      let(:action_name) { :some_action }
      let(:controller) { double('Controller') } # rubocop:disable RSpec/VerifiedDoubles
      let(:controller_class) { class_double(Controller) }
      let(:controller_configuration) { Controller::Configuration.new(controller) }
      let(:graphql_request) { GraphqlRails::Controller::Request.new(nil, {}, {}) }

      before do
        allow(controller).to receive(:class).and_return(controller_class)
        allow(controller_class).to receive(:controller_configuration).and_return(controller_configuration)
      end

      describe '#call' do
        it 'executes block in controller context' do
          instance = nil
          runner.call { instance = self }
          expect(instance).to be(controller)
        end

        it 'exectes given block' do
          expect { |b| runner.call(&b) }.to yield_control
        end

        context 'when before actions are defined' do
          include_context 'with action hooks', :before

          it 'runs all before actions', :aggregate_failures do
            runner.call {}
            expect(controller).to have_received(:before_action1).ordered
            expect(controller).to have_received(:before_action2).ordered
          end

          it 'executes given block' do
            expect { |b| runner.call(&b) }.to yield_control
          end
        end

        context 'when after actions are defined' do
          include_context 'with action hooks', :after

          it 'runs all after actions', :aggregate_failures do
            runner.call {}
            expect(controller).to have_received(:after_action1).ordered
            expect(controller).to have_received(:after_action2).ordered
          end

          it 'executes given block' do
            expect { |b| runner.call(&b) }.to yield_control
          end
        end

        context 'when around actions are defined' do
          include_context 'with around action hooks'

          it 'runs all around actions', :aggregate_failures do
            runner.call {}
            expect(controller).to have_received(:around_action1).ordered
            expect(controller).to have_received(:around_action2).ordered
          end

          it 'executes given block' do
            expect { |b| runner.call(&b) }.to yield_control
          end
        end

        context 'when various actions are defined' do
          include_context 'with action hooks', :after
          include_context 'with action hooks', :before
          include_context 'with around action hooks'

          it 'executes actions in correct order', :aggregate_failures do # rubocop:disable RSpec/ExampleLength
            runner.call {}
            expect(controller).to have_received(:before_action1).ordered
            expect(controller).to have_received(:before_action2).ordered
            expect(controller).to have_received(:around_action1).ordered
            expect(controller).to have_received(:around_action2).ordered
            expect(controller).to have_received(:after_action1).ordered
            expect(controller).to have_received(:after_action2).ordered
          end

          it 'executes given block once' do
            expect { |b| runner.call(&b) }.to yield_control
          end
        end

        context 'when anonymous hook is defined' do
          it 'is executed in controller context' do
            instance = nil
            controller_configuration.add_action_hook(:before) { instance = self }
            runner.call {}
            expect(instance).to be(controller)
          end
        end
      end
    end
  end
end
