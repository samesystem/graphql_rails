# Routes

Routes are generated via `GraphqlRails::Router.draw` method. It is very similar to rails router, except that instead of `match`, `get`, `post` actions you have `query` and `mutation` actions. In most cases you will use `resources` action. It works same as in rails router.

Here is simple router example:

```ruby
MyGraphqlSchema = GraphqlRails::Router.draw do
  # generates `friend`, `createFriend`, `updateFriend`, `destroyFriend`, `friends` routes
  resources :friends
  resources :shops, only: [:show, :index] # generates `shop` and `shops` routes only
  resources :orders, except: :update # generates all routes except `updateOrder`

  resources :users do
    # generates `findUser` query
    query :find, on: :member

    # generates `searchUsers` query
    query :search, on: :collection
  end

  # you can use namespaced controllers too:
  scope module: 'admin' do
    # `updateTranslations` route will be handeled by `Admin::TranslationsController`
    mutation :updateTranslations, to: 'translations#update'

    # all :groups routes will be handeled by `Admin::GroupsController`
    resources :groups
  end
end
```

## resources

`resources` method generates routes to `index`, `show`, `create`, `update` and `destroy` controller actions.

### _only_ and _except_ option

If you want to exclude some actions you can use `only` or `except` options.

```ruby
MyGraphqlSchema = GraphqlRails::Router.draw do
  resouces :users
  resouces :friends, only: :index
  resouces :posts, except: [:destroy, :index]
end
```

### custom actions

Sometimes it's handy so have non-CRUD actions in your controller. To define such route you can call `resources` with a block:

```ruby
MyGraphqlSchema = GraphqlRails::Router.draw do
  resouces :users do
    mutation :changePassword, on: :member
    query :active, on: :collection
  end
end
```

#### Appending name to the end of resource name

Sometimes, especially when working with member queries, it sounds better when action name is added to the end of resource name instead of start. To do so, you can add `suffix: true` to route:

```ruby
MyGraphqlSchema = GraphqlRails::Router.draw do
  resouces :users do
    query :details, on: :member, suffix: true
  end
end
```

This will generate `userDetails` field on GraphQL side.

## _query_ and _mutation_ & _subscription_

in case you want to have non-CRUD controller with custom actions you can define your own `query`/`mutation` actions like this:

```ruby
MyGraphqlSchema = GraphqlRails::Router.draw do
  mutation :logIn, to: 'sessions#login'
  query :me, to: 'users#current_user'
  subscribtion :new_message, to: 'messages#created'
end
```

## _scope_

### _module_ options

currently `scope` method accepts single option: `module`. `module` allows to specify controller namespace. So you can use scoped controllers, like so:

```ruby
MyGraphqlSchema = GraphqlRails::Router.draw do
  scope module: 'admin/top_secret' do
    mutation :logIn, to: 'sessions#login' # this will trigger Admin::TopSecret::SessionsController
  end

  mutation :logIn, to: 'sessions#login' # this will trigger ::SessionsController
end
```

## _group_

You can have multiple routers / schemas. In order to add resources or query only to specific schema, you need wrap it with `group` method, like this:

```ruby
GraphqlRouter = GraphqlRails::Router.draw do
  resources :users # goes to all routers

  group :mobile, :internal do
    resources :admin_users # goes to `mobile` and `internal` schemas
  end

  query :runTesting, to: 'testing#run', group: :testing # goes to `testing` schema
end
```

In order to call specific schema you can call it using `QueryRunner` in your RoR controller:

```ruby
class InternalController < ApplicationController
  def execute
    GraphqlRails::QueryRunner.new(group: :internal, params: params)
  end
end
```

If you want to access raw graphql schema, you can call `GraphqlRouter.graphql_schema(:mobile)`
