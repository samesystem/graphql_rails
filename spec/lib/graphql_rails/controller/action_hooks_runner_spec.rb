# frozen_string_literal: true

require 'spec_helper'

module GraphqlRails
  class Controller
    RSpec.describe ActionHooksRunner do
      shared_context 'with action filters' do |type|
        before do
          [:"#{type}_action1", :"#{type}_action2"].each do |action_filter_name|
            controller_configuration.public_send("add_#{type}_action", action_filter_name)
            allow(controller).to receive(action_filter_name)
          end
        end
      end

      shared_context 'with around action filters' do
        before do
          %i[around_action1 around_action2].each do |action_filter_name|
            controller_configuration.add_around_action(action_filter_name)
            allow(controller).to receive(action_filter_name).and_yield
          end
        end
      end

      subject(:runner) { described_class.new(action_name: action_name, controller: controller) }

      let(:action_name) { :some_action }
      let(:controller) { double('Controller') } # rubocop:disable RSpec/VerifiedDoubles
      let(:controller_class) { class_double(Controller) }
      let(:controller_configuration) { Controller::Configuration.new }

      before do
        allow(controller).to receive(:class).and_return(controller_class)
        allow(controller_class).to receive(:controller_configuration).and_return(controller_configuration)
      end

      describe '#call' do
        context 'when no action is defined' do
          it 'exectes given block' do
            expect { |b| runner.call(&b) }.to yield_control
          end
        end

        context 'when before actions are defined' do
          include_context 'with action filters', :before

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
          include_context 'with action filters', :after

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
          include_context 'with around action filters'

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
          include_context 'with action filters', :after
          include_context 'with action filters', :before
          include_context 'with around action filters'

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
      end
    end
  end
end
