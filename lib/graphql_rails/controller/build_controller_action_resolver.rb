# frozen_string_literal: true

require 'graphql_rails/controller/action'
require 'graphql_rails/concerns/service'
require 'graphql_rails/controller/action_configuration'
require 'graphql_rails/controller/build_controller_action_resolver/controller_action_resolver'

module GraphqlRails
  class Controller
    # graphql resolver which redirects actions to appropriate controller and controller action
    class BuildControllerActionResolver
      include ::GraphqlRails::Service

      def initialize(route:)
        @route = route
      end

      def call # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
        action = build_action

        Class.new(ControllerActionResolver) do
          type(*action.type_args)
          description(action.description)
          controller(action.controller)
          controller_action_name(action.name)

          action.arguments.each do |attribute|
            argument(*attribute.input_argument_args)
          end

          def self.inspect
            "ControllerActionResolver(#{controller.name}##{controller_action_name})"
          end
        end
      end

      private

      attr_reader :route

      def build_action
        Action.new(route).tap do |action|
          assert_action(action)
        end
      end

      def assert_action(action)
        action.return_type
      end
    end
  end
end
