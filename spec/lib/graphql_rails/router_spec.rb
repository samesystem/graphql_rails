# frozen_string_literal: true

require 'spec_helper'

module GraphqlRails
  RSpec.describe Router do
    class CustomDummyController < GraphqlRails::Controller
      action(:action).returns(:string!)
      action(:action2).returns(:string!)
    end

    class RouterDummyUsersController < GraphqlRails::Controller
      %i[create show update destroy index].each { |name| action(name).returns(:string!) }
    end

    subject(:router) { described_class.new }

    describe '.draw' do
      subject(:drawn_routes) do
        described_class.draw do
          scope module: :graphql_rails do
            query 'custom_query', to: 'custom_dummy#action'
            resources :router_dummy_users
          end
        end
      end

      it 'returns child class of GraphQl::Schema' do
        expect(drawn_routes < GraphQL::Schema).to be true
      end

      it 'remembers router' do
        expect { drawn_routes }.to change(described_class.routers, :keys).to([:default])
      end

      context 'when building routes for the second time' do
        let(:draw_additional_queries) do
          described_class.draw do
            query 'custom_query2', to: 'graphql_rails/custom_dummy#action2'
          end
        end

        before do
          drawn_routes
        end

        it 'updates existing router' do
          router = described_class.routers[:default]
          expect { draw_additional_queries }.to change(router.routes, :count).from(6).to(7)
        end
      end
    end

    describe '#rescue_from' do
      it 'allows rescuing from errors', :aggregate_failures do
        expect(router.tap(&:reload_schema).graphql_schema.rescues).to be_empty
        router.rescue_from(StandardError) { 'ups!' }
        expect(router.tap(&:reload_schema).graphql_schema.rescues).to include(StandardError)
      end
    end

    describe '#scope' do
      context 'with nested scopes' do
        before do
          router.scope module: 'foo' do
            query :find_foo_user, to: 'users#find'

            scope module: 'bar' do
              query :find_bar_user, to: 'users#find'
            end
          end
        end

        it 'generates correct controller action paths' do
          action_paths = router.routes.map(&:path)
          expect(action_paths).to match_array(%w[foo/bar/users#find foo/users#find])
        end
      end

      context 'with resoures in scope' do
        before do
          router.scope module: 'foo' do
            resources :users, only: :index do
              query :find
            end
          end
        end

        it 'generates correct controller action paths' do
          action_paths = router.routes.map(&:path)

          expect(action_paths).to match_array(%w[foo/users#index foo/users#find])
        end
      end
    end

    describe '#query' do
      it 'adds new query to the list' do
        expect { router.query('findUser', to: 'users#find') }
          .to change(router.routes, :count).by(1)
      end
    end

    describe '#mutation' do
      it 'adds new mutation to the list' do
        expect { router.mutation('createUser', to: 'users#create') }
          .to change(router.routes, :count).by(1)
      end
    end

    describe '#resources' do
      context 'without action hooks' do
        it 'adds CRUD actions' do
          expect { router.resources(:users) }
            .to change { router.routes.map(&:name) }
            .from([]).to(%w[user users createUser updateUser destroyUser])
        end
      end

      context 'with "only" action hook' do
        it 'adds only specified CRUD actions' do
          expect { router.resources(:users, only: :show) }
            .to change { router.routes.map(&:name) }
            .from([]).to(%w[user])
        end
      end

      context 'with "except" action hook' do
        it 'adds only specified CRUD actions' do
          expect { router.resources(:users, except: %i[show create]) }
            .to change { router.routes.map(&:name) }
            .from([]).to(%w[users updateUser destroyUser])
        end
      end

      context 'with extra actions' do
        before do
          router.resources :users, only: [] do
            query :custom, on: :member
            query :custom, on: :collection
            mutation :change_some
          end
        end

        it 'adds extra actions' do
          expect(router.routes.map(&:name)).to match_array %w[customUser customUsers changeSomeUser]
        end
      end

      context 'with suffix param' do
        before do
          router.resources :users, only: [] do
            query :friends, on: :member, suffix: true
            mutation :change_some, on: :collection, suffix: true
          end
        end

        it 'adds actions with suffix' do
          expect(router.routes.map(&:name)).to match_array %w[userFriends usersChangeSome]
        end
      end
    end
  end
end
