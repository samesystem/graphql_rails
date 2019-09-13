# frozen_string_literal: true

module GraphqlRails
  # no-doc
  module Generators
    require 'rails/generators/base'

    # Add GraphQL to a Rails app with `rails g graphql_rails:install`.
    #
    # Setup a folder structure for GraphQL:
    #
    # ```
    # - app/
    #   - controllers
    #     - graphql_controller.rb
    #     - graphql
    #       - graphql_application_controller.rb
    # - config
    #   - initializers
    #     - graphql.rb
    #   - graphql
    #     - routes.rb
    # ```
    class InstallGenerator < Rails::Generators::Base
      desc 'Install GraphqlRails folder structure and boilerplate code'

      source_root File.expand_path('../templates', __FILE__) # rubocop:disable Style/ExpandPathArguments

      def create_folder_structure
        empty_directory('app/controllers')
        template('graphql_controller.erb', 'app/controllers/graphql_controller.rb')

        empty_directory('app/controllers/graphql')
        template('graphql_application_controller.erb', 'app/controllers/graphql_application_controller.rb')

        empty_directory('config/graphql')
        template('routes.erb', 'config/graphql/routes.rb')

        template('initializer.erb', 'config/initializers/graphql_rails.rb')

        route('post "/graphql", to: "graphql#execute"')
      end
    end
  end
end
