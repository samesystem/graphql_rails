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

This method must be called inside your model body. `grapqhl` is used for making your model convertible to graphql type.

## attribute

Most commonly you will use `attribute` to make your model methods and attributes visible via graphql endpoint.

## attribute type

Some types can be determined by attribute name, so you can skip this attribute:

* attributes which ends with name `*_id` has `ID` type
* attributes which ends with `?` has `Boolean` type
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
    c.attribute :shop_id # ID type
    c.attribute :full_name # String type
    c.attribute :admin? # Boolean type
    c.attribute :level, type: 'integer'
    c.attribute :money, type: 'float'
  end
end
```

### attribute property

By default graphql attribute names are expected to be same as model methods/attributes, but if you want to use different name on grapqhl side, you can use `propery` option:

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

### attribute description

You can also describe each attribute and make graphql documentation even more readable. To do so, add `description` option:

```ruby
class User
  include GraphqlRails::Model

  graphql do |c|
    c.attribute :shop_id, description: 'references to shop'
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
