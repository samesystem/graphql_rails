# frozen_string_literal: true

require 'spec_helper'

module GraphqlRails
  class Controller
    RSpec.describe BuildControllerActionResolver do
      module Dummy
        module Foo
          class User
            include Model
            graphql do |c|
              c.attribute :name
            end
          end

          class UsersController < GraphqlRails::Controller
            action(:show).permit(:name!).returns(User.to_s)
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

      describe '.call' do
        subject(:call) do
          described_class.call(route: route)
        end

        it 'returns child class of ControllerActionResolver' do
          expect(call < BuildControllerActionResolver::ControllerActionResolver).to be true
        end

        it 'returns class with correct arguments' do
          expect(call.arguments.keys).to eq(%w[name])
        end

        it 'returns class with correct type' do
          expect(call.type).to eq(Dummy::Foo::User.graphql.graphql_type)
        end
      end
    end
  end
end
