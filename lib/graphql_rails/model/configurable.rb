# frozen_string_literal: true

module GraphqlRails
  module Model
    # Contains methods which are shared between various configurations.
    #
    # Expects `default_name` to be defined.
    # Expects `build_attribute(attr_name)` method to be defined.
    module Configurable
      require 'active_support/concern'
      require 'graphql_rails/concerns/chainable_options'

      extend ActiveSupport::Concern

      included do
        include GraphqlRails::ChainableOptions

        chainable_option :description
      end

      def initialize_copy(other)
        super
        @type_name = nil
        @attributes = other.attributes.transform_values(&:dup)
      end

      def attributes
        @attributes ||= {}
      end

      def name(*args)
        get_or_set_chainable_option(:name, *args) || default_name
      end

      def type_name
        @type_name ||= "#{name.camelize}Type#{SecureRandom.hex}"
      end

      def attribute(attribute_name, **attribute_options)
        key = attribute_name.to_s

        attributes[key] ||= build_attribute(attribute_name).tap do |new_attribute|
          new_attribute.with(**attribute_options) unless attribute_options.empty?
          yield(new_attribute) if block_given?
        end
      end
    end
  end
end
