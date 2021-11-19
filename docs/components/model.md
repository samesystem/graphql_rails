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

available types are:

* ID: `'id'`
* String: `'string'`, `'str'`, `'text'`
* Boolean: `'bool'`, `'boolean'`
* Float: `'float'`, `'double'`, `'decimal'`

usage example:

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

  graphql.attribute :address, type: AddressType, required: true
end
```

Check [graphql-ruby documentation](https://graphql-ruby.org) for more details about graphql-ruby types.

### attribute.property

By default graphql attribute names are expected to be same as model methods/attributes, but if you want to use different name on grapqhl side, you can use `property` option:

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

### attribute.paginated

You can mark collection method as `paginated`. In this case method will return relay connection type and it will be possible to return only partial results. No need to do anything on method side (you should always return full list of items)

```ruby
class User
  include GraphqlRails::Model

  graphql.attribute :items, type: '[Item]', paginatted: true

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

By default grapqhl type name will be same as model name, but you can change it via `name` method

```ruby
class User
  include GraphqlRails::Model

  graphql do |c|
    c.name 'Employee'
  end
end
```

## description

To improve grapqhl documentation, you can description for your graphql type:

```ruby
class User
  include GraphqlRails::Model

  graphql do |c|
    c.description 'Users are awesome!'
  end
end
```

## graphql_type

Sometimes it's handy to get raw graphql type. To do so you can call:

```ruby
YourModel.graphql.grapqhl_type
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
