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
    # Same as `.permit(amount: :integer!)`
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
class OrderController < GraphqlRails::Controller
  # this is the input with email and full_name:
  action(:create)
    .permit_input(:input, type: 'User!')

  # this is the input with password and password_confirmation:
  action(:update_password)
    .permit_input(:input, type: 'User!', subtype: :change_password)
end
```

### *can_return_nil*

By default it is expected that each controller action returns model or array of models. `nil` is not allowed. You can change that by adding `can_return_nil` like this:

```ruby
class UsersController < GraphqlRails::Controller
  action(:show).permit(:email).can_return_nil

  def show
    user = User.find_by(email: params[:email])
    return nil if user.blank?
    user
  end
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

Also check ['decorating controller responses']('components/decorator') for more details about working with active record and decorators.

#### *max_page_size*

Allows to specify max items count per request

```ruby
class UsersController < GraphqlRails::Controller
  action(:index).paginated(max_page_size: 10) # add max items limit

  def index
    User.all # it will render 10 users even you have more
  end
end
```

### *returns*

By default return type is determined by controller name. When you want to return some custom object, you can specify that with `returns` method:

```ruby
class UsersController < GraphqlRails::Controller
  action(:last_order).permit(:id).returns('Order!') # Order is your model class name

  def last_order
    user = User.find(params[:id]).orders.last
  end
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

  def require_auth_token
    raise 'Admin not authenticated' unless Admin.where(token: params[:admin_token]).exist?
  end
end
```

## decorating objects

See ['Decorating controller responses']('components/decorator') for various options how you can decorate paginated responses
