# frozen_string_literal: true

require 'spec_helper'
require 'active_record'

module GraphqlRails
  RSpec.describe Controller do
    DummyUserInput = GraphQL::InputObjectType.define {}

    class DummyInputsController < GraphqlRails::Controller
      action(:create).permit(:id, user!: DummyUserInput)
    end

    class DummyBeforeActionsController < GraphqlRails::Controller
      before_action :filter1
      before_action :filter2
      before_action :filter3

      def filter1; end

      def filter2; end

      def filter3; end
    end

    class DummyBeforeActionsFiltersController < GraphqlRails::Controller
      before_action :filter_for_only, only: :action_with_only_option
      before_action :filter_for_except, except: :action_with_except_option

      def filter_for_only; end

      def filter_for_except; end

      def action_with_no_option; end

      def action_with_except_option; end

      def action_with_only_option; end
    end

    class DummyMultipleBeforeActionsController < GraphqlRails::Controller
      before_action :filter
      before_action :filter, only: :action

      def action; end

      def filter; end
    end

    class DummyMultipleAnonymousAroundActionsController < GraphqlRails::Controller
      # rubocop:disable Style/Semicolon
      around_action { |controller, block| controller.log << 'around_action_1'; block.call }
      around_action { |controller, block| controller.log << 'around_action_2'; block.call }
      around_action(except: :action) { |controller| controller.log << 'around_action_3'; block.call }
      # rubocop:enable Style/Semicolon

      def log
        @log ||= []
      end
    end

    class DummyWithAroundActionWithValueController < GraphqlRails::Controller
      action(:original).returns('String!')

      around_action { |_controller, block| block.call; 'around_value' } # rubocop:disable Style/Semicolon

      def original
        'original_value'
      end
    end

    class DummyWithAllActionFiltersController < GraphqlRails::Controller
      around_action :around_action1
      around_action :around_action2
      after_action :after_action1
      after_action :after_action2
      before_action :before_action1
      before_action :before_action2

      def action; end

      def log
        @log ||= []
      end

      private

      def before_action1
        log << 'before_action1'
      end

      def before_action2
        log << 'before_action2'
      end

      def after_action1
        log << 'after_action1'
      end

      def after_action2
        log << 'after_action2'
      end

      def around_action1
        log << 'before around_action1'
        yield
        log << 'after around_action1'
      end

      def around_action2
        log << 'before around_action2'
        yield
        log << 'after around_action2'
      end
    end

    class DummyCallController < GraphqlRails::Controller
      DummyDecorator = Class.new(SimpleDelegator)

      attr_accessor :response_object

      def initialize(*args)
        super
        @response_object = 'Hello'
      end

      def respond_with_render
        render response_object
        'This should not be returned'
      end

      def respond_with_rendered_errors
        render error: 'bam!'
        response_object
      end

      def respond_with_decorator
        decorate(response_object, with: DummyDecorator)
      end

      def respond_with_raised_error
        raise StandardError, 'ups!'
      end

      def respond_without_render
        'Hello without render!'
      end
    end

    class DummyMultipleBeforeActionsParentController < DummyMultipleBeforeActionsController
      before_action :parent_filter
    end

    class DummyMultipleBeforeActionsChildController < DummyMultipleBeforeActionsParentController
      before_action :child_filter
    end

    subject(:controller) do
      DummyCallController.new(request).tap { |c| c.response_object = raw_response_object }
    end

    let(:raw_response_object) { 'Hello' }
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

      it 'logs with correct params' do
        log = nil
        log_key = Controller::LogControllerAction::START_PROCESSING_KEY
        ActiveSupport::Notifications.subscribe(log_key) { |*_, it| log = it }

        call
        expect(log).to eq(action: controller_action, controller: DummyCallController.name, params: {})
      end

      context 'when before action hooks are set on parent and child controller' do
        let(:controller) { DummyMultipleBeforeActionsChildController.new(request) }

        it 'contains parent and child actions' do
          before_hooks = \
            DummyMultipleBeforeActionsChildController
            .controller_configuration
            .action_hooks_for(:before, :any).map(&:name)

          expect(before_hooks).to eq %i[parent_filter child_filter]
        end

        it 'does not modify parent config' do
          before_hooks = \
            DummyMultipleBeforeActionsParentController
            .controller_configuration
            .action_hooks_for(:before, :any).map(&:name)

          expect(before_hooks).to eq [:parent_filter]
        end
      end

      context 'when various before action hooks are set' do
        let(:controller) { DummyWithAllActionFiltersController.new(request) }

        it 'triggers all action filters in correct order' do # rubocop:disable RSpec/ExampleLength
          controller.call(:action)
          expect(controller.log).to eq(
            [
              'before_action1', 'before_action2',
              'before around_action1', 'before around_action2',
              'after around_action2', 'after around_action1',
              'after_action1', 'after_action2'
            ]
          )
        end
      end

      context 'when before action hooks are set' do
        let(:controller) { DummyBeforeActionsController.new(request) }

        context 'when before action with same filter is specified more than once' do
          let(:controller) { DummyMultipleBeforeActionsController.new(request) }
          let(:controller_action) { :action }

          before do
            allow(controller).to receive(:filter)
          end

          it 'triggers filter only once' do
            call
            expect(controller).to have_received(:filter).once
          end
        end

        context 'when `only` or `except` actions are given' do
          let(:controller) { DummyBeforeActionsFiltersController.new(request) }

          before do
            allow(controller).to receive(:filter_for_except)
            allow(controller).to receive(:filter_for_only)
          end

          context 'when before action filter has `except` option' do
            context 'when action was included in `except` option' do
              let(:controller_action) { :action_with_except_option }

              it 'does not trigger before action filter' do
                call
                expect(controller).not_to have_received(:filter_for_except)
              end
            end

            context 'when action was not included in `except` option' do
              let(:controller_action) { :action_with_no_option }

              it 'triggers before action filter' do
                call
                expect(controller).to have_received(:filter_for_except)
              end
            end
          end

          context 'when before action has `only` option' do
            context 'when action was included in `only` option' do
              let(:controller_action) { :action_with_only_option }

              it 'triggers before action filter' do
                call
                expect(controller).to have_received(:filter_for_only)
              end
            end

            context 'when action was not included in `only` option' do
              let(:controller_action) { :action_with_no_option }

              it 'does not trigger before action filter' do
                call
                expect(controller).not_to have_received(:filter_for_only)
              end
            end
          end
        end

        context 'when before_action raises error' do
          let(:error) { StandardError.new('Boom!') }

          before do
            allow(controller).to receive(:filter2).and_raise(error)
          end

          it 'does not raise error' do
            expect { call }.not_to raise_error
          end

          it 'adds first error in to context' do
            call
            expect(context).to have_received(:add_error).once
          end

          it 'stops executing before actions after first failure' do
            allow(controller).to receive(:filter3)
            call
            expect(controller).not_to have_received(:filter3)
          end
        end
      end

      context 'when anonymous action hooks are set' do
        let(:controller) { DummyMultipleAnonymousAroundActionsController.new(request) }

        context 'when running action which was not included in "only" or "except" optio' do
          it 'runs all hooks' do
            controller.call(:any)
            expect(controller.log).to eq %w[around_action_1 around_action_2 around_action_3]
          end
        end

        context 'when running action which was included in "only" or "except" option' do
          it 'runs only hooks based on "only" and "except" options' do
            controller.call(:action)
            expect(controller.log).to eq %w[around_action_1 around_action_2]
          end
        end

        context 'when anonymous around action has some code after calling yield' do
          let(:controller) { DummyWithAroundActionWithValueController.new(request) }

          it 'returns value from action and not from hook' do
            expect(controller.call(:original)).to eq 'original_value'
          end
        end
      end

      context 'when decorator is used' do
        let(:controller_action) { :respond_with_decorator }

        it 'returns decorator instance' do
          expect(call).to be_a(DummyCallController::DummyDecorator)
        end

        context 'when response is nil' do
          let(:raw_response_object) { nil }

          it { is_expected.to be_nil }
        end

        context 'when response is instance of ActiveRecord::Relation' do
          let(:raw_response_object) { instance_double(ActiveRecord::Relation) }

          before do
            allow(raw_response_object).to receive(:is_a?).with(ActiveRecord::Relation).and_return(true)
          end

          it 'returns decorator' do
            expect(call).to be_a(Controller::RelationDecorator)
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
            expect(call).to eq 'Hello'
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
