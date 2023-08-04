# frozen_string_literal: true

require 'spec_helper'
module GraphqlRails
  class DummyUser
    include GraphqlRails::Model
  end

  class Controller
    RSpec.describe Action do
      class CustomDummyUsersController < GraphqlRails::Controller; end
      class DummyUsersController < GraphqlRails::Controller
        action(:show).returns(GraphQL::Types::String.to_non_null_type)
        action(:paginated_index).paginated
      end

      subject(:action) { described_class.new(route) }

      let(:action_name) { 'show' }

      let(:route) do
        Router::QueryRoute.new(
          :dummy_users,
          to: route_path,
          module: 'graphql_rails/controller',
          on: route_type
        )
      end

      let(:route_type) { :member }
      let(:controller_name) { 'dummy_users' }
      let(:route_path) { "#{controller_name}##{action_name}" }

      describe '#controller' do
        it 'returns correct controller class' do
          expect(action.controller).to be(DummyUsersController)
        end
      end

      describe '#return_type' do
        subject(:return_type) { action.return_type }

        context 'when action configuration specifies return type' do
          it 'uses specified type' do
            expect(return_type).to eq(GraphQL::Types::String.to_non_null_type)
          end
        end
      end

      describe '#action_config' do
        it 'returns action configuration' do
          expect(action.action_config).to be_a(ActionConfiguration)
        end

        it 'returns action configuration with correct attributes' do
          expect(action.action_config).to have_attributes(
            name: action_name
          )
        end
      end
    end
  end
end
