# frozen_string_literal: true

require 'graphql_rails/controller/request'
require 'graphql_rails/types/argument_type'

module GraphqlRails
  class Controller
    class BuildControllerActionResolver
      # Resolver which includes controller specific methods.
      # Used to simplify resolver build for each controller action
      class ControllerActionResolver < GraphQL::Schema::Resolver
        argument_class(GraphqlRails::Types::ArgumentType)

        def self.controller(controller_class = nil)
          @controller = controller_class if controller_class
          @controller
        end

        def self.controller_action_name(name = nil)
          @controller_action_name = name if name
          @controller_action_name
        end

        def resolve(**inputs)
          request = Request.new(object, inputs, context)
          self.class.controller.new(request).call(self.class.controller_action_name)
        end
      end
    end
  end
end
