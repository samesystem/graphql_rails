# Graphiti

[![Build Status](https://travis-ci.org/povilasjurcys/graphiti.svg?branch=master)](https://travis-ci.org/povilasjurcys/graphiti)

Rails style structure for GrapQL API.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'graphiti'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install graphiti

## Usage

### Define GraphQL schema as RoR routes

```ruby
MyGraphqlSchema = Graphiti::Router.draw do
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
  include Graphiti::Model

  graphiti do |c|
    # most common attributes, like :id, :name, :title has default type, so you don't have to specify it (but you can!)
    c.attribute :id

    c.attribute :email, :string
    c.attribute :surname, :string
  end
end
```

### Define controller

```ruby
class UsersController < Graphiti::Controller
  # graphql requires to describe which attributes controller action accepts and which returns
  action(:change_user_password)
    .permit(:password!, :id!) # Bang (!) indicates that attribute is required

  def change_user_password
    user = User.find(params[:id])
    user.update!(password: params[:password])

    # returned value needs to have all methods defined in model `graphiti do` part
    user # or SomeDecorator.new(user)
  end

  action(:search).permit(search_fields!: SearchFieldsInput) # you can specify your own input fields
  def search
  end
end
```

## Routes

```ruby
MyGraphqlSchema = Graphiti::Router.draw do
  # generates `friend`, `createFriend`, `updateFriend`, `destroyFriend`, `friends` routes
  resources :friends 
  
  resources :users do
    # generates `findUser` query
    query :find, on: :member 
    
    # generates `searchUsers` query
    query :search, on: :collection 
  end
  
  # you can use namespaced controllers too:
  scope module: 'admin' do
    # `updateTranslations` route will be handeled by `Admin::TranslationsController`
    mutation :updateTranslations, to: 'translations#update`
    
    # all :groups routes will be handeled by `Admin::GroupsController`
    resources :groups
  end
end
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/[USERNAME]/graphiti. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the Graphiti project’s codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/[USERNAME]/graphiti/blob/master/CODE_OF_CONDUCT.md).
