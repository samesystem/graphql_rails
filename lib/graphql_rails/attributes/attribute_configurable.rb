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
        chainable_option :extras, default: []
        chainable_option :type
      end

      def groups(new_groups = ChainableOptions::NOT_SET)
        @groups ||= []
        return @groups if new_groups == ChainableOptions::NOT_SET

        @groups = Array(new_groups).map(&:to_s)
        self
      end

      def group(*args)
        groups(*args)
      end

      def hidden_in_groups(new_groups = ChainableOptions::NOT_SET)
        @hidden_in_groups ||= []
        return @hidden_in_groups if new_groups == ChainableOptions::NOT_SET

        @hidden_in_groups = Array(new_groups).map(&:to_s)
        self
      end

      def required(new_value = true) # rubocop:disable Style/OptionalBooleanParameter
        @required = new_value
        self
      end

      def optional(new_value = true) # rubocop:disable Style/OptionalBooleanParameter
        required(!new_value)
      end

      def deprecated(reason = 'Deprecated')
        @deprecation_reason = \
          if [false, nil].include?(reason)
            nil
          else
            reason.is_a?(String) ? reason : 'Deprecated'
          end

        self
      end

      def deprecation_reason
        @deprecation_reason
      end

      def property(new_value = ChainableOptions::NOT_SET)
        return @property if new_value == ChainableOptions::NOT_SET

        @property = new_value.to_s
        self
      end

      def same_as(other_attribute)
        other = other_attribute.dup
        other.instance_variables.each do |instance_variable|
          next if instance_variable == :@initial_name

          instance_variable_set(instance_variable, other.instance_variable_get(instance_variable))
        end

        self
      end
    end
  end
end
