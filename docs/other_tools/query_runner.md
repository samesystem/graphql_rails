# Query Runner

`GraphqlRails::QueryRunner` is a helper class which let's you graphql queries in RoR controller without worrying about parsing details. Here is an example how to use it:

```ruby
class MyRailsClass < ApplicationController
  def execute
    graphql_result = GraphqlRails::QueryRunner.call(
      params: params, router: GraphqlRouter
    )

    render json: graphql_result
  end
end
```

## Executing grouped schema

If you have multiple schemas (read [routes section](components/routes) on how to do that) and you want to render group specific schema, you need to provide group name, like this:

```ruby
class MyRailsClass < ApplicationController
  def execute
    graphql_result = GraphqlRails::QueryRunner.call(
      group: :internal, # <- custom group name. Can by anything
      params: params, router: GraphqlRouter
    )

    render json: graphql_result
  end
end
```

## Providing graphql-ruby options

All graphql-ruby options are also supported, like [execution options](https://graphql-ruby.org/queries/executing_queries.html) or [visibility options](https://graphql-ruby.org/schema/limiting_visibility.html):

```ruby
class MyRailsClass < ApplicationController
  def execute
    graphql_result = GraphqlRails::QueryRunner.call(
      validate: true, # <- graphql-ruby option
      params: params, router: GraphqlRouter
    )

    render json: graphql_result
  end
end
```
