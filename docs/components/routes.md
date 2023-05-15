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
    # `updateTranslations` route will be handled by `Admin::TranslationsController`
    mutation :updateTranslations, to: 'translations#update'

    # all :groups routes will be handled by `Admin::GroupsController`
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
  resources :users
  resources :friends, only: :index
  resources :posts, except: [:destroy, :index]
end
```

### custom actions

Sometimes it's handy so have non-CRUD actions in your controller. To define such route you can call `resources` with a block:

```ruby
MyGraphqlSchema = GraphqlRails::Router.draw do
  resources :users do
    mutation :changePassword, on: :member
    query :active, on: :collection
  end
end
```

#### Appending name to the end of resource name

Sometimes, especially when working with member queries, it sounds better when action name is added to the end of resource name instead of start. To do so, you can add `suffix: true` to route:

```ruby
MyGraphqlSchema = GraphqlRails::Router.draw do
  resources :users do
    query :details, on: :member, suffix: true
  end
end
```

This will generate `userDetails` field on GraphQL side.

## _query_ and _mutation_ & _event_

In case you want to have non-CRUD controller with custom actions you can define your own `query`/`mutation` actions like this:

```ruby
MyGraphqlSchema = GraphqlRails::Router.draw do
  mutation :logIn, to: 'sessions#login'
  query :me, to: 'users#current_user'
end

Subscriptions are not really controller actions with a single response type, thus, they're defined differently. In GraphQL you subscribe to event, for example `userCreated`. To do this in graphql_rails you would define `event :user_created` in router definition.

```ruby
MyGraphqlSchema = GraphqlRails::Router.draw do
  mutation :logIn, to: 'sessions#login'
  query :me, to: 'users#current_user'

  event :user_created # expects Subscriptions::UserCreatedSubscription class to be present
  event :user_deleted, subscription_class: 'Subscriptions::UserDeletedSubscription'
end
```

## _scope_

### _module_ options

If you want to want to route everything to controllers, located at `controllers/admin/top_secret`, you can use scope with `module` param:

```ruby
scope module: 'admin/top_secret' do
  mutation :logIn, to: 'sessions#login' # this will trigger Admin::TopSecret::SessionsController
end
```

### Named scope

If you want to nest some routes under some other node, you can use named scope:

```ruby
scope :admin do
  mutation :logIn, to: 'sessions#login' # this will trigger ::SessionsController
end
```

This action will be accessible via:

```graphql
mutation {
  admin {
    logIn(email: 'john@example.com') { ... }
  }
}
```

## _namespace_

You may wish to organize groups of controllers under a namespace. Most commonly, you might group a number of administrative controllers under an `Admin::` namespace, and place these controllers under the app/controllers/admin directory. You can route to such a group by using a namespace block:

```ruby
  namespace :admin do
    resources :articles, only: :show
  end
```

On GraphQL side, you can reach such route with the following query:

```graphql
query {
  admin {
    article(id: '123') { ... }
  }
}
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
