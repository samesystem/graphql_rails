# frozen_string_literal: true

module GraphqlRails
  # Used to load rake tasks in RoR app
  class Railtie < Rails::Railtie
    rake_tasks do
      load 'graphql_rails/tasks/schema.rake'
    end
  end
end
