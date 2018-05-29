# frozen_string_literal: true

require 'spec_helper'

module GraphqlRails
  class Controller
    RSpec.describe GraphqlRails::Controller::ControllerFunction do
      subject(:function) do
        described_class.from_route(route)
      end

      module Dummy
        module Foo
          class User
            include Model
            graphql do |c|
              c.attribute :name
            end
          end

          class UsersController < GraphqlRails::Controller
            action(:show).permit(:name!)
            def show
              render 'show:OK'
            end
          end
        end
      end

      let(:route) do
        Router::QueryRoute.new(:users, on: :member, to: route_path, module: 'graphql_rails/controller/dummy/foo')
      end

      let(:route_path) { 'users#show' }

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

        let(:action_config) do
          instance_double(
            ActionConfiguration,
            return_type: action_config_return_type,
            description: nil,
            can_return_nil?: can_return_nil
          )
        end

        let(:action_config_return_type) { nil }
        let(:can_return_nil) { false }

        before do
          action = Action.new(route)
          allow(Action).to receive(:new).and_return(action)
          allow(action).to receive(:action_config).and_return(action_config)
          allow(action).to receive(:arguments).and_return([])
        end

        context 'when action has specified type' do
          let(:action_config_return_type) { GraphQL::STRING_TYPE }

          context 'when not allowed to return nil' do
            it 'ignores "can_return_nil" options and returns original type' do
              expect(type).to eq action_config.return_type
            end
          end

          context 'when allowed to return nil' do
            let(:can_return_nil) { true }

            it 'ignores "can_return_nil" options and returns original type' do
              expect(type).to eq action_config.return_type
            end
          end
        end

        context 'when action did not specify any return type' do
          context 'when not allowed to return nil' do
            it 'returns type from controller related mode with non null requirement' do
              expect(type).to eq Dummy::Foo::User.graphql.graphql_type.to_non_null_type
            end
          end

          context 'when allowed to return nil' do
            let(:can_return_nil) { true }

            it 'returns type from controller related model' do
              expect(type).to eq Dummy::Foo::User.graphql.graphql_type
            end
          end
        end
      end
    end
  end
end
