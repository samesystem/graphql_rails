# frozen_string_literal: true

module GraphqlRails
  module Model
    # contains methods which are shared between various configurations
    # expects `default_name` to be defined
    module Configurable
      def initialize_copy(other)
        super
        @name = nil
        @type_name = nil
        @description = nil
        @attributes = other.attributes.transform_values(&:dup)
      end

      def attributes
        @attributes ||= {}
      end

      def name(graphql_name = nil)
        @name = graphql_name if graphql_name
        @name || default_name
      end

      def type_name
        @type_name ||= "#{name.camelize}Type#{SecureRandom.hex}"
      end

      def description(new_description = nil)
        @description = new_description if new_description
        @description
      end

      def attribute(attribute_name, **attribute_options)
        key = attribute_name.to_s

        attributes[key] ||= build_attribute(attribute_name).tap do |new_attribute|
          new_attribute.with(attribute_options)
          yield(new_attribute) if block_given?
        end
      end

      private

      def build_attribute(_name)
        raise NotImplementedError
      end
    end
  end
end
