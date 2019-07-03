# Logging and monitoring

GraphqlRails behaves similar as Ruby on Rails. This allows to use existing monitoring and logging tools. Here we will add some examples on how to setup various tools for GraphqlRails

## Instrumentation

GraphqlRails uses same instrumentation tool (`ActiveSupport::Notifications`) as Rails. At the moment there are two notification types:

* `process_action.graphql_action_controller`
* `start_action.graphql_action_controller`

you can watch those actions using with `ActiveSupport::Notifications#subscribe` like this:

```ruby
key = 'process_action.graphql_action_controller'
ActiveSupport::Notifications.subscribe() do |*_, payload|
  YourLogger.do_something(payload)
end
```

or you can do the same with `ActiveSupport::LogSubscriber`. More details about it [here](https://api.rubyonrails.org/classes/ActiveSupport/LogSubscriber.html).

## Lograge

To enable lograge logging, you need to create subscriber:

```ruby
# lib/lograge/log_subscribers/graphql_action_controller
require 'lograge'

module Lograge
  module LogSubscribers
    class GraphqlActionController < ::Lograge::LogSubscribers::Base
      def process_action(event)
        process_main_event(event)
      end
    end
  end
end
```

and add initializer which subscribes to graphql rails actions:

```ruby
# config/initializers/lograge.rb
Lograge::LogSubscribers::GraphqlActionController.attach_to :graphql_action_controller
```

that's it - you should see GraphQL logs now.

## Sentry

In order to improve sentry logs, you need to change Raven context. In order to do so, add it to your GraphqlRails::Controller:

```ruby
# app/controllers/graphql/graphql_application_controller.rb
class Graphql::GraphqlApplicationController < GraphqlRails::Controller
  around_action :log_to_sentry

  def log_to_sentry
    Raven.context.transaction.pop
    Raven.context.transaction.push "#{self.class}##{action_name}"
    yield
  rescue Exception => error
    Raven.capture_exception(error, {}) unless error.is_a?(GraphQL::ExecutionError)
    raise error
  end
```

It's sad that crashes are happening, but at least now you can see them in sentry
