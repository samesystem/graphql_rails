# GraphqlRails

[![Build Status](https://travis-ci.org/povilasjurcys/graphql_rails.svg?branch=master)](https://travis-ci.org/povilasjurcys/graphql_rails)
[![codecov](https://codecov.io/gh/povilasjurcys/graphql_rails/branch/master/graph/badge.svg)](https://codecov.io/gh/povilasjurcys/graphql_rails)

Rails style structure for GrapQL API.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'graphql_rails'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install graphql_rails

## Usage

### Define GraphQL schema as RoR routes

```ruby
MyGraphqlSchema = GraphqlRails::Router.draw do
  # will create createUser, updateUser, deleteUser mutations and user, users queries.
  # expects that UsersController class exist
  resources :users

  # if you want custom queries or mutation
  query 'searchLogs', to: 'logs#search' # redirects request to LogsController
  mutation 'changeUserPassword', to: 'users#change_password'
end
```

### Define your Graphql model

```ruby
class User # works with any class including ActiveRecord
  include GraphqlRails::Model

  graphql do |c|
    # most common attributes, like :id, :name, :title has default type, so you don't have to specify it (but you can!)
    c.attribute :id

    c.attribute :email, :string
    c.attribute :surname, :string
  end
end
```

### Define controller

```ruby
class UsersController < GraphqlRails::Controller
  # graphql requires to describe which attributes controller action accepts and which returns
  action(:change_user_password)
    .permit(:password!, :id!) # Bang (!) indicates that attribute is required

  def change_user_password
    user = User.find(params[:id])
    user.update!(password: params[:password])

    # returned value needs to have all methods defined in model `graphql do` part
    user # or SomeDecorator.new(user)
  end

  action(:search).permit(search_fields!: SearchFieldsInput) # you can specify your own input fields
  def search
  end
end
```

## Routes

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

## Testing your GrapqhlRails::Controller in RSpec

### Setup

Add those lines in your `spec/spec_helper.rb` file

```ruby
# spec/spec_helper.rb
require 'graphql_rails/rspec_controller_helpers'

RSpec.configure do |config|
  config.include(GraphqlRails::RSpecControllerHelpers, type: :graphql_controller)
  # ... your other configuration ...
end
```

### Helper methods

There are 3 helper methods:

* `mutation(:your_controller_action_name, params: {}, context: {})`. `params` and `context` are optional
* `query(:your_controller_action_name, params: {}, context: {})`. `params` and `context` are optional
* `response`. Response is set only after you call `mutation` or `query`

### Test examples

```ruby
class MyGraphqlController
  def index
    "Called from index: #{params[:message]}"
  end

  action(:create_user).permit(:full_name, :email)
  def create_user
    User.create!(params)
  end
end

RSpec.describe MyGraphqlController, type: :graphql_controller do
  describe '#index' do
    it 'is successful' do
      query(:index)
      expect(response).to be_successful
    end

    it 'returns correct message' do
      query(:index, params: { message: 'Hello world!' })
      expect(response.result).to eq "Called from index: Hello world!"
    end
  end

  describe '#create_user' do
    context 'when bad email is given' do
      it 'fails' do
        mutation(:create_user, params { email: 'bad' })
        expect(response).to be_failure
      end

      it 'contains errors' do
        mutation(:create_user, params { email: 'bad' })
        expect(response.errors).not_to be_empty
      end
    end
  end
end
```


## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/[USERNAME]/graphql_rails. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the GraphqlRails project’s codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/[USERNAME]/graphql_rails/blob/master/CODE_OF_CONDUCT.md).
