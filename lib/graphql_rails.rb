# frozen_string_literal: true

require 'active_support/core_ext/module/delegation'

require 'graphql_rails/version'
require 'graphql_rails/model'
require 'graphql_rails/router'
require 'graphql_rails/controller'
require 'graphql_rails/attributes'
require 'graphql_rails/decorator'
require 'graphql_rails/query_runner'
require 'graphql_rails/railtie' if defined?(Rails)

# wonders starts here
module GraphqlRails
  autoload :Integrations, 'graphql_rails/integrations'
end
