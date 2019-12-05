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
    #   - graphql
    #     - graphql_router.rb
    # ```
    class InstallGenerator < Rails::Generators::Base
      desc 'Install GraphqlRails folder structure and boilerplate code'

      source_root File.expand_path('../templates', __FILE__) # rubocop:disable Style/ExpandPathArguments

      def create_folder_structure
        empty_directory('app/controllers')
        template('graphql_controller.erb', 'app/controllers/graphql_controller.rb')

        empty_directory('app/controllers/graphql')
        template('graphql_application_controller.erb', 'app/controllers/graphql/graphql_application_controller.rb')
        template('example_users_controller.erb', 'app/controllers/graphql/example_users_controller.rb')

        application do
          "config.autoload_paths << 'app/graphql'"
        end

        empty_directory('app/graphql')
        template('graphql_router.erb', 'app/graphql/graphql_router.rb')

        route('post "/graphql", to: "graphql#execute"')

        if File.directory?('spec') # rubocop:disable Style/GuardClause
          empty_directory('spec/graphql')
          template('graphql_router_spec.erb', 'spec/app/graphql/graphql_router_spec.rb')
        end
      end
    end
  end
end
