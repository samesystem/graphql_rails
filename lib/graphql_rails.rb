# frozen_string_literal: true

require 'graphql_rails/version'
require 'graphql_rails/model'
require 'graphql_rails/router'
require 'graphql_rails/controller'
require 'graphql_rails/attributes'

# wonders starts here
module GraphqlRails
  autoload :Integrations, 'graphql_rails/integrations'
end
