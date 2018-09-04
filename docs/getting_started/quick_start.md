# Quick Start

## Define GraphQL schema as RoR routes

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

## Define your Graphql model

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

## Define controller

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

Congrats, you are done!
