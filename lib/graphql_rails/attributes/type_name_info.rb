# frozen_string_literal: true

module GraphqlRails
  module Attributes
    # checks various attributes based on graphql type name
    class TypeNameInfo
      attr_reader :name

      def initialize(name)
        @name = name
      end

      def nullable_inner_name
        inner_name[/[^!]+/]
      end

      def inner_name
        name[/[^!\[\]]+!?/]
      end

      def required_inner_type?
        inner_name.include?('!')
      end

      def list?
        name.include?(']')
      end

      def required?
        name.end_with?('!')
      end

      def required_list?
        required? && list?
      end
    end
  end
end
