# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Graphiti::Router do
  subject(:router) { described_class.new }

  describe '.draw' do
    subject(:drawn_routes) do
      described_class.draw do
        query 'custom_query', to: 'custom#action'
        resources :users
      end
    end

    it 'returns GraphQl::Schema' do
      expect(drawn_routes).to be_a(GraphQL::Schema)
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
        action_paths = router.actions.map(&:controller_action_path)
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
        action_paths = router.actions.map(&:controller_action_path)

        expect(action_paths).to match_array(%w[foo/users#index foo/users#find])
      end
    end
  end

  describe '#query' do
    it 'adds new query to the list' do
      expect { router.query('findUser', to: 'users#find') }
        .to change(router.actions, :count).by(1)
    end
  end

  describe '#mutation' do
    it 'adds new mutation to the list' do
      expect { router.mutation('createUser', to: 'users#create') }
        .to change(router.actions, :count).by(1)
    end
  end

  describe '#resources' do
    context 'without action filters' do
      it 'adds CRUD actions' do
        expect { router.resources(:users) }
          .to change { router.actions.map(&:name) }
          .from([]).to(%w[user users createUser updateUser destroyUser])
      end
    end

    context 'with "only" action filter' do
      it 'adds only specified CRUD actions' do
        expect { router.resources(:users, only: :show) }
          .to change { router.actions.map(&:name) }
          .from([]).to(%w[user])
      end
    end

    context 'with "except" action filter' do
      it 'adds only specified CRUD actions' do
        expect { router.resources(:users, except: %i[show create]) }
          .to change { router.actions.map(&:name) }
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
        expect(router.actions.map(&:name)).to match_array %w[customUser customUsers changeSomeUser]
      end
    end
  end
end
