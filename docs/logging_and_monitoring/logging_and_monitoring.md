# Logging and monitoring

GraphqlRails behaves similar as Ruby on Rails. This allows to use existing monitoring and logging tools. Here we will add some examples on how to setup various tools for GraphqlRails

## Integrating GraphqlRails with other tools

In order to make GraphqlRails work with tools such as lograge or sentry, you need to enable them. In Ruby on Rails, you can add initializer:

```ruby
# config/initializers/graphql_rails.rb
GraphqlRails::Integrations.enable(:lograge, :sentry)
```

At the moment, GraphqlRails supports following integrations:

* lograge
* sentry

## Instrumentation

GraphqlRails uses same instrumentation tool (`ActiveSupport::Notifications`) as Ruby on Rails. At the moment there are two notification types:

* `process_action.graphql_action_controller`
* `start_action.graphql_action_controller`

you can watch those actions using with `ActiveSupport::Notifications#subscribe` like this:

```ruby
key = 'process_action.graphql_action_controller'
ActiveSupport::Notifications.subscribe(key) do |*_, payload|
  YourLogger.do_something(payload)
end
```

or you can do the same with `ActiveSupport::LogSubscriber`. More details about it [here](https://api.rubyonrails.org/classes/ActiveSupport/LogSubscriber.html).
