# GraphqlRails

![Build Status](https://github.com/samesystem/graphql_rails/workflows/Ruby/badge.svg?branch=master)
[![codecov](https://codecov.io/gh/samesystem/graphql_rails/branch/master/graph/badge.svg)](https://codecov.io/gh/samesystem/graphql_rails)
[![Documentation](https://readthedocs.org/projects/ansicolortags/badge/?version=latest)](https://samesystem.github.io/graphql_rails)

Rails style structure for GraphQL API.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'graphql_rails'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install graphql_rails

## Getting started

Execute:

    $ bundle exec rails g graphql_rails:install

This will generate code which will let you start your graphql faster

## Usage

### Define GraphQL schema as RoR routes

```ruby
# config/graphql/routes.rb
GraphqlRails::Router.draw do
  # will create createUser, updateUser, destroyUser mutations and user, users queries.
  # expects that UsersController class exist
  resources :users

  # if you want custom queries or mutation
  query 'searchLogs', to: 'logs#search' # action is handled by LogsController#search
end
```

See [Routes docs](components/routes.md) for more info.

### Define your Graphql model

```ruby
# app/models/user.rb
class User # works with any class including ActiveRecord
  include GraphqlRails::Model

  graphql do |c|
    # most common attributes, like :id, :name, :title has default type, so you don't have to specify it (but you can!)
    c.attribute(:id)

    c.attribute(:email).type('String')
    c.attribute(:surname).type('String')
  end
end
```

See [Model docs](components/model.md) for more info.

### Define controller

```ruby
# app/controllers/graphql/users_controller.rb
class Graphql::UsersController < GraphqlApplicationController
  model('User') # specify that all actions returns User by default

  # DRUD actions description
  action(:index).permit(id: 'ID!').returns_many
  action(:show).permit(id: 'ID!').returns_single
  action(:create).permit(email: 'String!').returns_single
  action(:update).permit(id: 'ID!', email: 'String!').returns_single
  action(:destroy).permit(id: 'ID!').returns_single

  def index
    User.all
  end

  def show
    User.find(params[:id])
  end
  # ... code for create / update / destroy is skipped ...
end
```

See [Controller docs](components/controller.md) for more info.

## Testing your GraphqlRails::Controller in RSpec

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

See [Testing docs](testing/testing.md) for more info.

### Helper methods

There are 3 helper methods:

* `mutation(:your_controller_action_name, params: {}, context: {})`. `params` and `context` are optional
* `query(:your_controller_action_name, params: {}, context: {})`. `params` and `context` are optional
* `response`. Response is set only after you call `mutation` or `query`

### Test examples

```ruby
class MyGraphqlController
  action(:create_user).permit(:full_name, :email).returns(User)
  action(:index).returns('String')

  def index
    "Called from index: #{params[:message]}"
  end

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

### Integrating GraphqlRails with other tools

In order to make GraphqlRails work with tools such as lograge or sentry, you need to enable them. In Ruby on Rails, you can add initializer:

```ruby
# config/initializers/graphql_rails.rb
GraphqlRails::Integrations.enable(:lograge, :sentry)
```

At the moment, GraphqlRails supports following integrations:

* lograge
* sentry

If you need to build something custom, check [logging_and_monitoring documentation](logging_and_monitoring/logging_and_monitoring.md) for more details.

## Detailed documentation

Check https://samesystem.github.io/graphql_rails for more details

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/samesystem/graphql_rails. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the GraphqlRails project’s codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/samesystem/graphql_rails/blob/master/CODE_OF_CONDUCT.md).
