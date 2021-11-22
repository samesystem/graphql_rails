# frozen_string_literal: true

require 'graphql_rails/attributes/type_parser'
require 'graphql_rails/attributes/attribute_name_parser'
require 'graphql_rails/model/build_enum_type'
require 'graphql_rails/concerns/chainable_options'
require 'active_support/concern'

module GraphqlRails
  module Attributes
    # Allows to set or get various attribute parameters
    module AttributeConfigurable
      extend ActiveSupport::Concern

      included do
        include GraphqlRails::ChainableOptions

        chainable_option :description
        chainable_option :options, default: {}
        chainable_option :type
      end

      def required(new_value = true) # rubocop:disable Style/OptionalBooleanParameter
        @required = new_value
        self
      end

      def optional(new_value = true) # rubocop:disable Style/OptionalBooleanParameter
        required(!new_value)
      end
    end
  end
end
