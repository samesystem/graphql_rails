# Model

To make your model graphql-firendly, you need to inlcude `GraphqlRails::Model`. Your model can be any ruby class (PORO, ActiveRecord::Base or anything else)

Also you need to define which attributes can be exposed via graphql. To do so, use `graphql` method inside your model body. Example:

```ruby
class User # works with any class including ActiveRecord
  include GraphqlRails::Model

  graphql do |c|
    c.attribute :id
    c.full_name, type: :string
  end
end
```

## graphql

This method must be called inside your model body. `graphql` is used for making your model convertible to graphql type.

## attribute

Most commonly you will use `attribute` to make your model methods and attributes visible via graphql endpoint.

### attribute.type

Some types can be determined by attribute name, so you can skip this attribute:

* attributes which ends with name `*_id` has `ID!` type
* attributes which ends with `?` has `Boolean!` type
* all other attributes without type are considered to be `String`

Usage example:

```ruby
class User
  include GraphqlRails::Model

  graphql do |c|
    c.attribute :shop_id # ID! type
    c.attribute :full_name # String type
    c.attribute :admin? # Boolean! type
    c.attribute :level, type: 'integer'
    c.attribute :money, type: 'float'
  end
end
```

You can also use some build in aliases for types, such as:

* `'id'` is alias for `GraphQL::Types::ID`
* `'integer'`, `'int'` are aliases for `GraphQL::Types::Int`
* `'bigint'`, `'big_int'` are aliases for `GraphQL::Types::BigInt`
* 'float', 'double', 'decimal' are aliases for `GraphQL::Types::Float`
* `'bool'`, `'boolean'` are aliases for GraphQL::Types::Boolean
* String: `'string'`, `'str'`, `'text'`
* 'date' is alias for `GraphQL::Types::ISO8601Date`
* 'time', 'datetime', 'date_time' are aliases for `GraphQL::Types::ISO8601DateTime`
* 'json' is alias for `GraphQL::Types::JSON`

Usage example:

```ruby
class User
  include GraphqlRails::Model

  graphql do |c|
    c.attribute(:about_me).type(:text)
    c.attribute(:active).type('bool!')
    c.attribute(:created_at).type(:datetime!)
    c.attribute(:data).type(:json!)
    c.attribute(:login_dates).type('[date!]!')
  end
end
```

#### attribute.type: using graphql-ruby objects

You can also use raw graphql-ruby objects as attribute types. Here is an example:

```ruby
# raw graphql-ruby type:
class AddressType < GraphQL::Schema::Object
  graphql_name 'Address'

  field :city, String, null: false
  field :street_name, String, null: false
  field :street_number, Integer
end

# GraphqlRails model:
class User
  include GraphqlRails::Model

  graphql.attribute :address, type: 'AddressType!', required: true
end
```

Check [graphql-ruby documentation](https://graphql-ruby.org) for more details about graphql-ruby types.

### attribute.property

By default graphql attribute names are expected to be same as model methods/attributes, but if you want to use different name on graphql side, you can use `property` option:

```ruby
class User
  include GraphqlRails::Model

  graphql do |c|
    c.attribute :shop_id, property: :department_id
  end

  def department_id
    456
  end
end
```

### attribute.description

You can also describe each attribute and make graphql documentation even more readable. To do so, add `description` option:

```ruby
class User
  include GraphqlRails::Model

  graphql do |c|
    c.attribute :shop_id, description: 'references to shop'
  end
end
```

### attribute.deprecated

Attribute can be marked as deprecated with `deprecated` method:

```ruby
class User
  include GraphqlRails::Model

  graphql do |c|
    c.attribute(:legacy_name).deprecated
    c.attribute(:legacy_id).deprecated('This is my custom deprecation reason')
  end
end
```

### attribute.groups

Groups are handy feature when you want to have multiple schemas. For example, you want to have public graphql endpoint and internal graphql endpoint where each group has some unique nodes. If attribute has `groups` set, then this attribute will be visible only in appropriate group schemas.

```ruby
class User
  include GraphqlRails::Model

  graphql do |c|
    # visible in all schemas (default):
    c.attribute(:email)

    # visible in "internal" and "beta" schemas only:
    c.attribute(:admin_id).groups(%i[internal beta])

    # visible in "external" schema only:
    c.attribute(:nickname).groups(%i[external])
  end
end
```

### attribute.group

Alias for Attribute#groups.

```ruby
class User
  include GraphqlRails::Model

  graphql do |c|
    # visible in all schemas (default):
    c.attribute(:email)

    # visible in "external" schema only:
    c.attribute(:nickname).group(:external)
  end
end
```

### attribute.hidden_in_groups

Opposite for Attribute#groups. It hides attribute in given groups

```ruby
class User
  include GraphqlRails::Model

  graphql do |c|
    # visible in all schemas (default):
    c.attribute(:email)

    # visible in all schemas except "external":
    c.attribute(:nickname).hidden_in_groups(:external)
  end
end
```

### attribute.options

Allows passing options to attribute definition. Available options:

* `attribute_name_format` - if `:original` value is passed, it will not camelCase attribute name.

```ruby
class User
  include GraphqlRails::Model

  graphql do |c|
    c.attribute :first_name # will be accessible as firstName from client side
    c.attribute :first_name, options: { attribute_name_format: :original } # will be accessible as first_name from client side
  end
end
```

### attribute.extras

Allows passing extras to enable [graphql-ruby field extensions](https://graphql-ruby.org/type_definitions/field_extensions.html#using-extras)

```ruby
class User
  include GraphqlRails::Model

  graphql do |c|
    c.attribute(:items).extras([:lookahead])
  end
end
```

### attribute.permit

To define attributes which are accepted by each model method, you need to call `permit` method, like this:

```ruby
class User
  include GraphqlRails::Model

  graphql do |c|
    c.attribute(:avatar_url).permit(size: :int!)
  end

  def avatar_url(size:)
    # some code here
  end
end
```

### attribute.permit_input

Allows to permit single input field. It allows to set additional options for each field.

#### attribute.permit_input.type

#### attribute.permit_input: required type

There are few ways how to mark field as required.

1. Adding exclamation mark at the end of type name:

```ruby
class User
  include GraphqlRails::Model

  graphql.attribute(:avatar_url).permit_input(:size, type: :int!)
end
```

2. Adding `required: true` options

```ruby
class User
  include GraphqlRails::Model

  graphql.attribute(:avatar_url).permit_input(:size, type: :int, required: true)
end
```

#### attribute.permit_input.description

You can describe each input by adding `description` keyword argument:

```ruby
class User
  include GraphqlRails::Model

  graphql.attribute(:avatar_url).permit_input(:size, description: 'max size of avatar')
end
```

#### *subtype*

`subtype` allows to specify which named input should be used. Here is an example:

```ruby
class Image
  graphql.input(:size_options) do |c|
    c.attribute :width
    c.attribute :height
  end
end

class User
  graphql.attribute(:avatar_url).permit_input(:size, type: Image, subtype: :size_options)
end
```

#### *deprecated*

You can mark input input as deprecated with `deprecated` option:


```ruby
class User
  include GraphqlRails::Model

  graphql.attribute(:avatar_url)
         .permit_input(:size, type: :int!, deprecated: true)

  graphql.attribute(:logo_url)
         .permit_input(:size, type: :int!, deprecated: 'custom image size is deprecated')
end
```

### attribute.paginated

You can mark collection method as `paginated`. In this case method will return relay connection type and it will be possible to return only partial results. No need to do anything on method side (you should always return full list of items)

```ruby
class User
  include GraphqlRails::Model

  graphql.attribute :items, type: '[Item]', paginated: true

  def items
    Item.all
  end
end
```

### attribute.required

You can mark attribute as required using `required` method:

```ruby
class User
  include GraphqlRails::Model

  graphql.attribute(:item).type('Item').required
end
```

### attribute.optional

You can mark attribute as optional using `optional` method:

```ruby
class User
  include GraphqlRails::Model

  graphql.attribute(:item).type('Item').optional
end
```

### attribute.same_as

When you want to have identical attributes, you can use `Attribute#same_as` to make sure that attribute params will stay in sync:

```ruby
class User
  include GraphqlRails::Model

  graphql do |c|
    c.attribute(:user_id).type('ID').description('User ID')
    c.attribute(:person_id).same_as(c.attribute(:user_id))
  end
end
```

### attribute.with

When you want to define some options dynamically, it's quite handy to use "Attribute#with" method:

```ruby
class User
  include GraphqlRails::Model

  graphql do |c|
    c.attribute(:shop_id).with(type: 'ID', description: 'references to shop')
    # same as:
    # c.attribute(:shop_id, type: 'ID', description: 'references to shop')
    # also same as:
    # c.attribute(:shop_id).type('ID').description('references to shop')
  end
end
```

### "attribute" configuration with chainable methods

If your attribute definition is complex, you can define attribute in more eye-friendly chainable way with:

```ruby
class User
  include GraphqlRails::Model

  graphql do |c|
    c.attribute(:shop_id)
      .type('ID!')
      .description('references to shop')
  end
end
```

### "attribute" configuration with a block

You can also use block in order to specify attribute configuration:

```ruby
class User
  include GraphqlRails::Model

  graphql do |c|
    c.attribute(:shop_id) do |attr|
      attr.type 'ID!'
      attr.description 'references to shop'
    end
  end
end
```

## name

By default graphql type name will be same as model name, but you can change it via `name` method

```ruby
class User
  include GraphqlRails::Model

  graphql do |c|
    c.name 'Employee'
  end
end
```

## description

To improve graphql documentation, you can description for your graphql type:

```ruby
class User
  include GraphqlRails::Model

  graphql do |c|
    c.description 'Users are awesome!'
  end
end
```

## implements

`implements` indicates that graphql type implements one or more interfaces:

```ruby
module UserInterface
  include GraphQL::Schema::Interface
  # ....
end

module AdvancedUserInterface
  include GraphQL::Schema::Interface
  # ...
end

class AdminUser
  include GraphqlRails::Model

  graphql do |c|
    c.implements(UserInterface, AdvancedUserInterface)
  end
end
```

## graphql_type

Sometimes it's handy to get raw graphql type. To do so you can call:

```ruby
YourModel.graphql.graphql_type
```

## input

You can define input types:

```ruby
class User
  include GraphqlRails::Model

  graphql.input do |c|
    c.attribute :name
  end
end
```

Also you can have multiple input types:

```ruby
class User
  include GraphqlRails::Model

  graphql.input(:create) do |c|
    c.attribute :name
  end

  graphql.input(:update) do |c|
    c.attribute :id
    c.attribute :name
  end
end
```

### input attribute

Most commonly you will use `attribute` to define what kind of values your endpoint accepts

#### input type

You can specify your input attribute type. If type is not provided then type is set to `:string`.

```ruby
class User
  include GraphqlRails::Model

  graphql.input do |c|
    c.attribute :friends_count, type: :integer!
  end
end
```

### "input.attribute" configuration with chainable methods

If your input attribute definition is complex, you can define attribute in more eye-friendly chainable way with:

```ruby
class User
  include GraphqlRails::Model

  graphql.input do |c|
    c.attribute(:friends_count)
      .type(:integer!)
      .description('Can not be zero or less')
  end
end
```

#### required type

There are few ways how to mark field as required.

1. Adding exclamation mark at the end of type name:

```ruby
class User
  include GraphqlRails::Model

  graphql.input do |c|
    c.attribute :friends_count, type: :integer!
  end
end
```

2. Adding `required: true` value

```ruby
class User
  include GraphqlRails::Model

  graphql.input do |c|
    c.attribute :friends_count, type: :integer, required: true
  end
end
```

#### input enum type

You can specify your input attribute as enum:

```ruby
class User
  include GraphqlRails::Model

  graphql.input do |c|
    c.attribute :favorite_fruit, enum: %i[apple orange]
  end
end
```

By default enum type is not required. To make it required add `required: true`:

```ruby
class User
  include GraphqlRails::Model

  graphql.input do |c|
    c.attribute :favorite_fruit, required: true, enum: %i[apple orange]
  end
end
```

#### input attribute description

To improve graphql endpoint documentation, you can add description for each input attribute:

```ruby
class User
  include GraphqlRails::Model

  graphql.input do |c|
    c.attribute :name, description: "User's first name"
  end
end
```

#### input attribute deprecation

You can mark input attribute as deprecated with `deprecated` method:

```ruby
class User
  include GraphqlRails::Model

  graphql.input do |c|
    c.attribute(:full_name).deprecated('Use firstName and lastName instead')
    c.attribute(:surname).deprecated
  end
end
```

#### input attribute default value

You can set default value for input attribute:

```ruby
class User
  include GraphqlRails::Model

  graphql.input do |c|
    c.attribute(:is_admin).type('Boolean').default_value(false)
  end
end
```

#### input attribute config copy

You can copy existing config from other attribute using `Attribute#same_as` method:

```ruby
class User
  include GraphqlRails::Model

  graphql.input(:create) do |c|
    c.attribute(:first_name).type('String!')
    c.attribute(:last_name).type('String!')
  end

  graphql.input(:update) do |c|
    c.attribute(:id).type('ID!')
    graphql.input(:contract).attributes.each_value do |attr|
      c.attribute(attr.name).same_as(attr)
    end
  end
end
```

#### input attribute property

Sometimes it's handy to have different input attribute on graphql level and different on controller. That's when `Attribute#property` comes to the rescue:

```ruby
class Post
  include GraphqlRails::Model

  graphql.input do |c|
    c.attribute(:author_id).type('ID').property(:user_id)
  end
end
```

Then mutation such as:

```gql
mutation createPost(input: { authorId: 123 }) {
  author
}
```

Will pass `user_id` instead of `authorId` in controller:

```ruby
# posts_controller.rb
def create
  Post.create!(user_id: params[:input][:user_id])
end
```

## graphql_context

It's possible to access graphql_context in your model using method `graphql_context`:

```ruby
class User
  include GraphqlRails::Model

  def method_with_context
    graphql_context[:some_data]
  end
end
```

Keep in mind that this value will be set only during graphql execution, but in tests this value will be `nil`. To avoid this, you need to set `show_graphql_context` manually like this:

```ruby
class User
  include GraphqlRails::Model

  def show_graphql_context
    graphql_context[:data]
  end
end

user = User.new(...)
user.show_graphql_context #=> NoMethodError: undefined method `[]' for nil:NilClass
user.graphql_context =  { data: 'goes to context' }
user.show_graphql_context #=> { data: 'goes to context' }
```
