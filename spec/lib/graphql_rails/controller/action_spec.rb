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
        action(:show).returns(GraphQL::STRING_TYPE.to_non_null_type).can_return_nil
        action(:paginated_index).paginated
      end

      subject(:action) { described_class.new(route) }

      let(:action_name) { 'create' }

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
          let(:action_name) { 'show' }

          it 'uses specified type' do
            expect(return_type).to eq(GraphQL::STRING_TYPE.to_non_null_type)
          end
        end

        context 'when action configuration does not specify return type' do
          context 'when controller has model' do
            it 'generates type from controller model' do
              expect(return_type).to eq(DummyUser.graphql.graphql_type.to_non_null_type)
            end

            context 'when return type is for collection route' do
              let(:route_type) { :collection }

              context 'when action is paginated' do
                let(:action_name) { 'paginated_index' }

                it 'returns connection' do
                  expect(return_type.to_s).to eq 'DummyUserConnection'
                end
              end

              context 'when action is not paginated' do
                it 'returns list type' do
                  expect(return_type).to be_list
                end

                it 'returns non null type' do
                  expect(return_type).to be_non_null
                end
              end
            end

            context 'when return type is for member route' do
              it 'returns singular type' do
                expect(return_type).not_to be_list
              end

              it 'returns non null type' do
                expect(return_type).to be_non_null
              end
            end
          end

          context 'when controller does not have model' do
            let(:controller_name) { 'custom_dummy_users' }

            it 'raises exception' do
              expect { action.return_type }.to raise_error(Action::MissingConfigurationError)
            end
          end
        end
      end
    end
  end
end
