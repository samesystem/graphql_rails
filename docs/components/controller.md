# Controller

Each controller should inherit from `GraphqlRails::Controller`. It is handy to have `ApplicationGraphqlController`:

```ruby
class ApplicationGraphqlController < GraphqlRails::Controller
  # write your shared code here
end
```

## *action*

to specify details about each controller action, you need to call method `action` inside controller. For example:

```ruby
class ApplicationGraphqlController < GraphqlRails::Controller
  # write your shared code here
end
```

### *permit*

to define attributes which are accepted by each controller action, you need to call `permit` method, like this:

```ruby
class UsersController < GraphqlRails::Controller
  action(:create).permit(:id!, :some_string_value)

  def create
    User.create(params)
  end
end
```

permitted values will be available via `params` method in controller action. By default all attributes will have `String` type. Also you can add exclamation mark after attribute name if you want to forbid `nil` value for that attribute.

If you want to use custom input type, you can define it like this:

```ruby
class UsersController < GraphqlRails::Controller
  action(:create).permit(:id!, some_integer_value: :int!, something_custom: YourGraphqlInputType)

  def create
    User.create(params)
  end
end
```

If your model has defined input, then you can provide your model as input type, like this:

```ruby
class User
  graphql.input do
    c.attribute :name
  end
end

class UsersController < GraphqlRails::Controller
  action(:create).permit(create_params: 'User')
  # this is equivalent to:
  # `action(:create).permit(create_params: User.graphql.input)`

  def create
    User.create(params[:create_params])
  end
end
```

### *permit_input*

Allows to permit single input field. It allows to set additional options for each field.

#### *type*

Specifies input type:

```ruby
class OrderController < GraphqlRails::Controller
  action(:create)
    .permit_input(:price, type: :integer!)
    # Same as `.permit(price: :integer!)`
end
```

#### required type

There are few ways how to mark field as required.

1. Adding exclamation mark at the end of type name:

```ruby
class UsersController < GraphqlRails::Controller
  action(:create).permit_input(:some_field, type: :int!)
end
```

2. Adding exclamation mark at the end of name

```ruby
class UsersController < GraphqlRails::Controller
  action(:create).permit_input(:some_field!)
end
```

3. Adding `required: true` options

```ruby
class UsersController < GraphqlRails::Controller
  action(:create).permit_input(:some_field, type: :bool, required: true)
end
```

#### *description*

You can describe each input by adding `description` keyword argument:

```ruby
class OrderController < GraphqlRails::Controller
  action(:create)
    .permit_input(:price, type: :integer!, description: 'Price in Euro cents')
end
```

#### *subtype*

`subtype` allows to specify which named input should be used. Here is an example:

Let's say you have user with two input types

```ruby
class User
  graphql.input do |c|
    c.attribute :full_name
    c.attribute :email
  end

  graphql.input(:change_password) do |c|
    c.attribute :password
    c.attribute :password_confirmation
  end
end
```

If you do not specify `subtype` then default (without name) input will be used. You need to specify subtype if you want to use non-default input:

```ruby
class UsersController < GraphqlRails::Controller
  # this is the input with email and full_name:
  action(:create)
    .permit_input(:input, type: 'User!')

  # this is the input with password and password_confirmation:
  action(:update_password)
    .permit_input(:input, type: 'User!', subtype: :change_password)
end
```

#### *deprecated*

You can mark input input as deprecated with `deprecated` option:

```ruby
class UsersController < GraphqlRails::Controller
  action(:create)
    .permit_input(:input, type: 'User', deprecated: true)

  action(:update)
    .permit_input(:input, type: 'User', deprecated: 'use updateBasicUser instead')
end
```

### *paginated*

You can mark collection action as `paginated`. In this case controller will return relay connection type and it will be possible to return only partial results. No need to do anything on controller side (you should always return full list of items)

```ruby
class UsersController < GraphqlRails::Controller
  action(:index).paginated

  def index
    User.all
  end
end
```

Also check ['decorating controller responses'](components/decorator) for more details about working with active record and decorators.

#### *max_page_size*

Allows to specify max items count per request

```ruby
class UsersController < GraphqlRails::Controller
  action(:index).paginated(max_page_size: 10) # add max items limit

  def index
    User.all # it will render max 10 users even you have requested more
  end
end
```

#### *default_page_size*

Allows to specify max items count per request

```ruby
class UsersController < GraphqlRails::Controller
  action(:index).paginated(default_page_size: 5) # add default items per page size

  def index
    User.all # it will render 5 users even you have more
  end
end
```

### *model*

If you want to define model dynamically, you can use combination of `model` and `returns_list` or `returns_single`. This is especially handy when model is used with `action_default`:

```ruby
class OrdersController < GraphqlRails::Controller
  model('Order')
  action(:show).returns_single # returns `Order!`
  action(:index).returns_list # returns `[Order!]!`

  def show
    Order.first
  end

  def index
    Order.all
  end
end
```

### *returns*

You must specify what each action will return. This is done with `returns` method:

```ruby
class UsersController < GraphqlRails::Controller
  action(:last_order).permit(:id).returns('Order!') # Order is your model class name

  def last_order
    user = User.find(params[:id]).orders.last
  end
end
```

You can also return raw graphql-ruby types:

```ruby
# raw graphql-ruby type:
class OrderType < GraphQL::Schema::Object
  graphql_name 'Order'
  field :id, ID
end

class UsersController < GraphqlRails::Controller
  action(:last_order).permit(:id).returns(OrderType)
end
```

Check [graphql-ruby documentation](https://graphql-ruby.org) for more details about graphql-ruby types.

### *returns_list*

When you have defined `model` dynamically, you can use `returns_list` to indicate that action must return list without specifying model type for each action. By default list and inner types are required but you can change that with `required_list: false` and `required_inner: false`

```ruby
class OrdersController < GraphqlRails::Controller
  model('Order')

  action(:index).returns_list(required_list: false, required_inner: false) # returns `[Order]`
  action(:search).permit(:filter).returns_list # returns `[Order!]!`
end
```

### *returns_single*

When you have defined `model` dynamically, you can use `returns_single` to indicate that action must return single item without specifying model type for each action. By default return type is required, but you can change that by providing `required: false` flag:

```ruby
class OrdersController < GraphqlRails::Controller
  model('Order')

  action(:show).returns_single(required: false) # returns `Order`
  action(:update).permit(title: :string!).returns_single # returns `Order!`
end
```

### *describe*

If you want to improve graphql documentation, you can add description for each action. To do so, use `describe` method:

```ruby
class UsersController < GraphqlRails::Controller
  action(:create).describe('Creates user')

  def create
    User.create(params)
  end
end
```

### *options*

You can customize your queries using `options` method. So far we've added `input_format` and allowed value is `:original` which specifies to keep the field name format.
`options` method can be used like so:

```ruby
class UsersController < GraphqlRails::Controller
  action(:create).options(input_format: :original).permit(:full_name)

  def create
    User.create(params)
  end
end
```

### configuring action with a block

If you do not like chainable methods, you can use "block" style action configuration:

```ruby
class UsersController < GraphqlRails::Controller
  action(:index) do |action|
    action.paginated
    action.permit(limit: :int!)
    action.returns '[User!]!'
  end

  def create
    User.create(params)
  end
end
```

## *model*

`model` is just a shorter version of `action_default.model`. See `action.model` and `action_default` for more information:

```ruby
class OrdersController < GraphqlRails::Controller
  model('Order')
  action(:show).returns_single # returns `Order!`
  action(:index).returns_list # returns `[Order!]!`

  def show
    Order.first
  end

  def index
    Order.all
  end
end
```

## *action_default*

Sometimes you want to have some shared attributes for all your actions. In order to make this possible you need to use `action_default`. It acts identical to `action` and is "inherited" by all actions defined after `action_default` part:

```ruby
class UsersController < GraphqlRails::Controller
  action_default.permit(token: :string!)

  action(:update).returns('User!') # action(:update) has `permit(token: :string!)
  action(:create).returns('User') # action(:create) has `permit(token: :string!)
end
```

## *before_action*

You can add `before_action` to run some filters before calling your controller action. Here is an example:

```ruby
class UsersController < GraphqlRails::Controller
  before_action :require_auth_token

  def create
    User.create(params)
  end

  private

  def require_auth_token # will run before `UsersController#create` action
    raise 'Not authenticated' unless User.where(token: params[:token]).exist?
  end
end
```

## *after_action*

You can add `after_action` to run some filters after calling your controller action. Here is an example:

```ruby
class UsersController < GraphqlRails::Controller
  after_action :clear_cache

  def create
    User.create(params)
  end

  private

  def clear_cache # will run after `UsersController#create` action
    logger.log('Create action is completed')
  end
end
```

## *around_action*

You can add `around_action` to run some filters before and after calling your controller action. Here is an example:

```ruby
class UsersController < GraphqlRails::Controller
  around_action :use_custom_locale

  def create
    User.create(params)
  end

  private

  def with_custom_locale
    I18n.with_locale('it') do
      yield # yield is mandatory
    end
  end
end
```

## anonymous action filters

before/after/around action filters can be written as blocks too:

```ruby
class UsersController < GraphqlRails::Controller
  around_action do |controller, block|
    I18n.with_locale('it') do
      block.call
    end
  end

  def create
    User.create(params)
  end
end
```

it's not recommended but might be helpful in some edge cases.

### *only* and *except* option

`UsersController.before_action` accepts `only` or `except` options which allows to skip filters for some actions.

```ruby
class UsersController < GraphqlRails::Controller
  before_action :require_auth_token, except: :show
  before_action :require_admin_token, only: %i[update destroy]

  def create
    User.create(params)
  end

  def destroy
    User.create(params)
  end

  private

  def require_auth_token
    raise 'Not authenticated' unless User.where(token: params[:token]).exist?
  end

  def require_admin_token
    raise 'Admin not authenticated' unless Admin.where(token: params[:admin_token]).exist?
  end
end
```

## decorating objects

See ['Decorating controller responses'](components/decorator) for various options how you can decorate paginated responses

## Rendering errors

### Rendering strings as errors

The simplest way to render an error is to provide a list of error messages, like this:

```ruby
class UsersController < GraphqlRails::Controller
  action(:update).permit(:id, input: 'UserInput!').returns('User!')

  def update
    user = User.find(params[:id])

    if user.update(params[:input])
      user
    else
      render(errors: ['Something went wrong'])
    end
  end
end
```

### Rendering validation errors

GraphqlRails controller has `#render` method which you can use to render errors:

```ruby
class UsersController < GraphqlRails::Controller
  action(:update).permit(:id, input: 'UserInput!').returns('User!')

  def update
    user = User.find(params[:id])

    if user.update(params[:input])
      user
    else
      render(errors: user.errors)
    end
  end
end
```

### Rendering errors with custom data

When you want to return errors with custom data, you can provide hash like this:

```ruby
class UsersController < GraphqlRails::Controller
  action(:update).permit(:id, input: 'UserInput!').returns('User!')

  def update
    user = User.find(params[:id])

    if user.update(params[:input])
      user
    else
      render(
        errors: [
          { message: 'Something went wrong', code: 500, type: 'fatal' },
          { message: 'Something went wrong', custom_param: true, ... },
        ]
      )
    end
  end
end
```

### Raising custom error classes

If you want to have customized error classes you need to create errors which inherit from `GraphqlRails::ExecutionError`

```ruby
class MyCustomError < GraphqlRails::ExecutionError
  def to_h
    # this part will be rendered in graphql
    { something_custom: 'yes' }
  end
end

class UsersController < GraphqlRails::Controller
  action(:update).permit(:id, input: 'UserInput!').returns('User!')

  def update
    user = User.find(params[:id])

    if user.update(params[:input])
      user
    else
      raise MyCustomError, 'ups!'
    end
  end
end
```
