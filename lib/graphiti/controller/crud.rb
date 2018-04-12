# frozen_string_literal: true

module Graphiti
  module CRUD
    def included(klass)
      klass.specify(:create, accepts: klass.controller_configuration.default_input_type)
      klass.specify(:show, accepts: :id)
      klass.specify(:update, accepts: [:id, klass.controller_configuration.default_input_type])
      klass.specify(:destroy, accepts: :id)

      klass.specify(:index, returns: [klass.controller_configuration.default_return_type])
    end
  end
end
