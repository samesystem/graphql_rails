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

```ruby
class UsersController < GraphqlRails::Controller
  action(:create).describe('Creates user')

  def create
    User.create(params)
  end
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
  action(:last_order).permit(:id).returns(Order)

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
