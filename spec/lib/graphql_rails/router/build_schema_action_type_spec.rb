# frozen_string_literal: true

require 'spec_helper'
require 'support/dummy_app/dummy'

module GraphqlRails
  RSpec.describe Router::BuildSchemaActionType do
    describe '.call' do
      subject(:call) { described_class.call(type_name: type_name, routes: routes) }

      let(:type_name) { 'Test' }
      let(:routes) { router.routes }
      let(:router) { Router.new }

      context 'with no routes' do
        it 'returns GraphQL type with no fields' do
          expect(call.fields).to be_empty
        end
      end

      context 'with top level route' do
        before do
          router.query(:user, to: 'dummy/users#show')
        end

        it 'returns GraphQL type with fields matching routes', :aggregate_failures do
          expect(call.inspect).to eq('GraphQL::Schema::Object(Test)')
          expect(call.fields.keys).to match_array(%w[user])
        end
      end

      context 'with scoped and namespaced route' do
        before do
          router.namespace(:dummy) do
            scope :users_area do
              query(:user, to: 'users#show')
            end
          end
        end

        it 'returns GraphQL type with deep nested fields matching', :aggregate_failures do
          expect(call.fields.keys).to match_array(%w[dummy])

          dummy_namespace = call.fields['dummy'].type.unwrap
          expect(dummy_namespace.fields.keys).to match_array(%w[usersArea])

          users_area_scope = dummy_namespace.fields['usersArea'].type.unwrap
          expect(users_area_scope.fields.keys).to match_array(%w[user])
        end
      end
    end
  end
end
