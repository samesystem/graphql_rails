# frozen_string_literal: true

require 'graphql_rails/concerns/service'
require 'graphql_rails/controller/action_configuration'
require 'graphql_rails/controller/build_controller_action_resolver/controller_action_resolver'

module GraphqlRails
  class Controller
    # graphql resolver which redirects actions to appropriate controller and controller action
    class BuildControllerActionResolver
      include ::GraphqlRails::Service

      def initialize(action:)
        @action = action
      end

      def call # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
        action = self.action

        Class.new(ControllerActionResolver) do
          graphql_name("ControllerActionResolver#{SecureRandom.hex}")

          type(*action.type_args, **action.type_options)
          description(action.description)
          controller(action.controller)
          controller_action_name(action.name)

          action.arguments.each do |attribute|
            argument(*attribute.input_argument_args, **attribute.input_argument_options)
          end

          def self.inspect
            "ControllerActionResolver(#{controller.name}##{controller_action_name})"
          end
        end
      end

      private

      attr_reader :action
    end
  end
end
