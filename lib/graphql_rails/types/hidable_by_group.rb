# frozen_string_literal: true

require 'graphql_rails/types/argument_type'

module GraphqlRails
  module Types
    # Add visibility option based on groups
    module HidableByGroup
      def initialize(*args, groups: [], **kwargs, &block)
        super(*args, **kwargs, &block)

        @groups = groups.map(&:to_s)
      end

      def visible?(context)
        super && visible_in_context_group?(context)
      end

      private

      def groups
        @groups
      end

      def visible_in_context_group?(context)
        group = context[:graphql_group] || context['graphql_group']

        group.nil? || groups.empty? || groups.include?(group.to_s)
      end
    end
  end
end
