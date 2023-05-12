# frozen_string_literal: true

require_relative 'route'

module GraphqlRails
  class Router
    # stores subscription type graphql action info
    class EventRoute
      attr_reader :name, :module_name, :subscription_class, :groups, :scope_names

      def initialize(name, subscription_class: nil, groups: nil, scope_names: [], **options)
        @name = name.to_s.camelize(:lower)
        @module_name = options[:module].to_s
        @groups = groups
        @subscription_class = subscription_class
        @scope_names = scope_names
      end

      def show_in_group?(group_name)
        return true if groups.nil? || groups.empty?

        groups.include?(group_name&.to_sym)
      end

      def field_options
        { subscription: subscription }
      end

      def subscription
        if subscription_class.present?
          subscription_class.is_a?(String) ? Object.const_get(subscription_class) : subscription_class
        else
          klass_name = ['subscriptions/', name.underscore, 'subscription'].join('_').camelize

          Object.const_get(klass_name)
        end
      end

      def mutation?
        false
      end

      def query?
        false
      end

      def event?
        true
      end
    end
  end
end
