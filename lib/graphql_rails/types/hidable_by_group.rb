# frozen_string_literal: true

require 'graphql_rails/types/argument_type'

module GraphqlRails
  module Types
    # Add visibility option based on groups
    module HidableByGroup
      def initialize(*args, groups: [], hidden_in_groups: [], **kwargs, &block)
        super(*args, **kwargs, &block)

        @hidden_in_groups = hidden_in_groups.map(&:to_s)
        @groups = groups.map(&:to_s) - @hidden_in_groups
      end

      def visible?(context)
        super && visible_in_context_group?(context)
      end

      private

      def groups
        @groups
      end

      def hidden_in_groups
        @hidden_in_groups
      end

      def visible_in_context_group?(context)
        group = context_graphql_group(context)

        return true if no_visibility_configuration?(group)
        return groups.include?(group) unless groups.empty?

        !hidden_in_groups.include?(group)
      end

      def no_visibility_configuration?(group)
        return true if group.nil?

        groups.empty? && hidden_in_groups.empty?
      end

      def context_graphql_group(context)
        group = context[:graphql_group] || context['graphql_group']

        group.nil? ? nil : group.to_s
      end
    end
  end
end
