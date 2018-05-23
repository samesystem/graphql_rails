# frozen_string_literal: true

require 'spec_helper'
module GraphqlRails
  class DummyUser
    include GraphqlRails::Model
  end

  class Controller
    RSpec.describe Action do
      class DummyUsersController < GraphqlRails::Controller
        action(:show).returns(GraphQL::STRING_TYPE.to_non_null_type).can_return_nil
      end

      subject(:action) { described_class.new(route) }

      let(:action_name) { 'create' }

      let(:route) do
        Router::QueryRoute.new(
          :dummy_users,
          to: "dummy_users##{action_name}",
          module: 'graphql_rails/controller',
          on: route_type
        )
      end

      let(:route_type) { :member }

      describe '#controller' do
        it 'returns correct controller class' do
          expect(action.controller).to be(DummyUsersController)
        end
      end

      describe '#return_type' do
        subject(:return_type) { action.return_type }

        context 'when action configuration specifies return type' do
          let(:action_name) { 'show' }

          it 'uses specified type' do
            expect(return_type).to eq(GraphQL::STRING_TYPE.to_non_null_type)
          end
        end

        context 'when action configuration does not specify return type' do
          it 'generates type from controller model' do
            expect(action.return_type).to eq(DummyUser.graphql.graphql_type.to_non_null_type)
          end
        end
      end
    end
  end
end
