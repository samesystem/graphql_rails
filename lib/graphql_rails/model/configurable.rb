# frozen_string_literal: true

module GraphqlRails
  module Model
    # contains methods which are shared between various configurations
    # expects `default_name` to be defined
    module Configurable
      def attributes
        @attributes ||= {}
      end

      def name(type_name = nil)
        @name = type_name if type_name
        @name || default_name
      end

      def description(new_description = nil)
        @description = new_description if new_description
        @description
      end
    end
  end
end
