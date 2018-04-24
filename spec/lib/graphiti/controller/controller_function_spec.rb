# frozen_string_literal: true

require 'spec_helper'

module Graphiti
  class Controller
    RSpec.describe Graphiti::Controller::ControllerFunction do
      subject(:function) do
        described_class.build(action_path, module: 'graphiti/controller/dummy/foo')
      end

      module Dummy
        module Foo
          class User
            include Model
            graphiti do |c|
              c.attribute :name
            end
          end

          class UsersController < Graphiti::Controller
            action(:show).permit(:name!)
            def show
              render 'show:OK'
            end
          end
        end
      end

      let(:action_path) { 'users#show' }

      describe '.build' do
        it 'returns instance of ControllerFunction' do
          expect(function).to be_a(ControllerFunction)
        end

        it 'returns instance which is not direct child of ControllerFunction' do
          expect(function.class).not_to eq(ControllerFunction)
        end
      end

      describe '#arguments' do
        it 'returns correct arguments' do
          expect(function.arguments.keys).to eq(%w[name])
        end
      end

      describe '#call' do
        it 'triggers controller action' do
          expect(function.call(nil, nil, nil)).to eq 'show:OK'
        end
      end

      describe '#type' do
        subject(:type) { function.type }

        let(:action) do
          instance_double(
            ActionConfiguration,
            return_type: action_return_type,
            can_return_nil?: can_return_nil
          )
        end

        let(:action_return_type) { nil }
        let(:can_return_nil) { false }

        before do
          action_parser = ActionPathParser.new(action_path, module: 'graphiti/controller/dummy/foo')
          allow(ActionPathParser).to receive(:new).and_return(action_parser)
          allow(action_parser).to receive(:action).and_return(action)
          allow(action_parser).to receive(:arguments).and_return([])
        end

        context 'when action has specified type' do
          let(:action_return_type) { GraphQL::STRING_TYPE }

          context 'when not allowed to return nil' do
            it 'returns type from action with non null requirement' do
              expect(type).to eq action.return_type.to_non_null_type
            end
          end

          context 'when allowed to return nil' do
            let(:can_return_nil) { true }

            it 'returns original type from action' do
              expect(type).to eq action.return_type
            end
          end
        end

        context 'when action did not specify any return type' do
          context 'when not allowed to return nil' do
            it 'returns type from controller related mode with non null requirement' do
              expect(type).to eq Dummy::Foo::User.graphiti.graphql_type.to_non_null_type
            end
          end

          context 'when allowed to return nil' do
            let(:can_return_nil) { true }

            it 'returns type from controller related model' do
              expect(type).to eq Dummy::Foo::User.graphiti.graphql_type
            end
          end
        end
      end
    end
  end
end
