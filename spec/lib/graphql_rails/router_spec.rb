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

      it 'returns instance of router' do
        expect(drawn_routes).to be_a(described_class)
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

        it 'does not modify existing router' do
          expect { draw_additional_queries }.not_to change(drawn_routes.routes, :count)
        end
      end
    end

    describe '#graphql_schema' do
      subject(:graphql_schema) { router.graphql_schema(group_name) }

      let(:group_name) { nil }

      let(:router) do
        described_class.draw do
          scope module: :graphql_rails do
            query 'custom_query', to: 'custom_dummy#action'
            resources :router_dummy_users, only: %i[index show]

            group :secret do
              resources :router_dummy_users, only: %i[create]

              query 'single_secret_grouped_custom_query', to: 'custom_dummy#action'
            end

            group :secret, :top_secret do
              query 'shared_secret_grouped_custom_query', to: 'custom_dummy#action'
            end

            query 'top_secret_query', to: 'custom_dummy#action', group: :top_secret
          end
        end
      end

      it 'returns child class of GraphQl::Schema' do
        expect(graphql_schema < GraphQL::Schema).to be true
      end

      context 'when some resource action are defined under group scope' do
        it 'does not include resouce routes defined in groups' do
          expect(graphql_schema.to_definition).not_to include('createRouterDummyUser')
        end
      end

      context 'when calling schema without group name' do
        it 'does not return grouped routes' do
          expect(graphql_schema.to_definition).not_to include('singleSecretGroupedCustomQuery')
        end
      end

      context 'when mutation actions are not defined' do
        let(:router) do
          described_class.draw do
            scope module: :graphql_rails do
              query 'custom_query', to: 'custom_dummy#action'
            end
          end
        end

        it 'returns schema without mutation type' do # rubocop:disable RSpec/ExampleLength
          expect(graphql_schema.to_definition).to eq(
            <<~GRAPHQL
              type Query {
                customQuery: String!
              }
            GRAPHQL
          )
        end
      end

      context 'when query actions are not defined' do
        let(:router) do
          described_class.draw do
            scope module: :graphql_rails do
              mutation 'custom_query', to: 'custom_dummy#action'
              subscription 'record_created', to: 'custom_dummy#action'
            end
          end
        end

        it 'returns schema with empty query type' do # rubocop:disable RSpec/ExampleLength
          expect(graphql_schema.to_definition).to eq(
            <<~GRAPHQL
              type Mutation {
                customQuery: String!
              }

              type Query {
              }

              type Subscription {
                recordCreated: String!
              }
            GRAPHQL
          )
        end
      end

      context 'when calling schema with group name' do
        let(:group_name) { :secret }

        it 'includes grouped routes' do
          expect(graphql_schema.to_definition).to include('singleSecretGroupedCustomQuery')
        end

        it 'includes routes from shared groups' do
          expect(graphql_schema.to_definition).to include('sharedSecretGroupedCustomQuery')
        end

        it 'does not include routes from other groups' do
          expect(graphql_schema.to_definition).not_to include('topSecretQuery')
        end

        it 'includes resouce actions defined under given group' do
          expect(graphql_schema.to_definition).to include('createRouterDummyUser')
        end
      end
    end

    describe '#rescue_from' do
      it 'allows rescuing from errors' do
        expect { router.rescue_from(StandardError) { 'ups!' } }.to(
          change { router.tap(&:reload_schema).graphql_schema.error_handler.find_handler_for(StandardError) }
            .from(nil)
            .to(hash_including(class: StandardError))
        )
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
              subscription :created
            end
          end
        end

        it 'generates correct controller action paths' do
          action_paths = router.routes.map(&:path)

          expect(action_paths).to match_array(%w[foo/users#index foo/users#find foo/users#created])
        end
      end

      context 'when scope is in a group' do
        before do
          router.group :scope_group do
            scope module: 'foo' do
              query :find_foo_user, to: 'users#find'
            end
          end
        end

        it 'makes scope routes visible in specified group' do
          route = router.routes.first
          expect(route).to be_show_in_group(:scope_group)
        end

        it 'makes scope routes hidden in not specified groups' do
          route = router.routes.first
          expect(route).not_to be_show_in_group(:other_group)
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
        context 'when extra action is written in underscore format' do
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

          it 'generates correct paths' do
            expect(router.routes.map(&:path)).to match_array %w[users#change_some users#custom users#custom]
          end
        end

        context 'when extra action is in camelcase' do
          before do
            router.resources :users, only: [] do
              query :customAction, on: :member
            end
          end

          it 'adds extra actions' do
            expect(router.routes.map(&:name)).to match_array %w[customActionUser]
          end

          it 'generates correct paths' do
            expect(router.routes.map(&:path)).to match_array %w[users#custom_action]
          end
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
