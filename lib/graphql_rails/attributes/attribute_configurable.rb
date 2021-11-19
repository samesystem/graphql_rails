# frozen_string_literal: true

require 'graphql_rails/attributes/type_parser'
require 'graphql_rails/attributes/attribute_name_parser'
require 'graphql_rails/model/build_enum_type'

module GraphqlRails
  module Attributes
    # Allows to set or get various attribute parameters
    module AttributeConfigurable
      NOT_SET = Object.new

      def with(**attribute_options)
        attribute_options.each do |method_name, args|
          send_args = [method_name]
          send_args << args if method(method_name).parameters.present?
          public_send(*send_args)
        end
        self
      end

      def required(new_value = true) # rubocop:disable Style/OptionalBooleanParameter
        @required = new_value
        self
      end

      def optional(new_value = true) # rubocop:disable Style/OptionalBooleanParameter
        required(!new_value)
      end

      def type(new_type = NOT_SET)
        return @type if new_type == NOT_SET

        @type = new_type
        self
      end

      def description(new_description = NOT_SET)
        return @description if new_description == NOT_SET

        @description = new_description
        self
      end

      def options(new_options = NOT_SET)
        @options ||= {}
        return @options if new_options == NOT_SET

        @options = new_options
        self
      end
    end
  end
end
