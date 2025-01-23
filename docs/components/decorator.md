# Decorator

Decorator is mostly used whit paginated results, because it can wrap ActiveRecord relations in a "pagination-friendly" way

## Passing extra options to decorator

Let's say you want to decorate `comment`, but you also need `user` in order to print some details. Here is decorator for such comment:

```ruby
class CommentDecorator < SimpleDelegator
  include GraphqlRails::Decorator

  def initialize(comment, current_user)
    @comment = comment
    @current_user = user
  end

  def author_name
    if @current_user.can_see_author_name?(@comment)
      @comment.author_name
    else
      'secret author'
    end
  end
end
```

In order to decorate object with extra arguments, simply pass them to `.decorate` method. Like this:

```ruby
CommentDecorator.decorate(comment, current_user)
```

The only requirement is that first object should be the object which you are decorating. Other arguments are treated as extra data and they are not modified

## Decorating controller responses

If you want to decorate your controller response you can use `GraphqlRails::Decorator` module. It can decorate simple objects and ActiveRecord::Relation objects. This is very handy when you need to decorated paginated actions:

```ruby
class User < ActiveRecord::Base
  # it's not GraphqlRails::Model !
end

class UserDecorator < SimpleDelegator
  include GraphqlRails::Model
  include GraphqlRails::Decorator

  graphql do |c|
    # some setup, attributes, etc...
  end

  def initialize(user); end
end

class UsersController < GraphqlRails::Controller
  action(:index).paginated.returns('[UserDecorator!]!')

  def index
    users = User.where(active: true)
    UserDecorator.decorate(users)
  end

  def create
    user = User.create(params)
    UserDecorator.decorate(user)
  end
end
```

## Decorating with custom method

Sometimes building decorator instance is not that straight-forward and you need to use custom build strategy. In such cases you can pass `build_with: :DESIRED_CLASS_METHOD` option:

```ruby
class UserDecorator < SimpleDelegator
  include GraphqlRails::Model
  include GraphqlRails::Decorator
  # ...

  def self.custom_build(user)
    user.admin? ? new(user, admin: true) : new(user)
  end

  def initialize(user, admin: false)
    @user = user
    @admin = admin
  end
end

class UsersController < GraphqlRails::Controller
  action(:index).paginated.returns('[UserDecorator!]!')

  def index
    users = User.where(active: true)
    UserDecorator.decorate(user, build_with: :custom_build)
  end
end
```
