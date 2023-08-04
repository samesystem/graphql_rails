# frozen_string_literal: true

require_relative '../controller/build_controller_action_resolver'
require 'graphql_rails/controller/action'

module GraphqlRails
  class Router
    # Generic class for any type graphql action. Should not be used directly
    class Route
      attr_reader :name, :module_name, :on, :relative_path, :groups, :scope_names

      def initialize(name, on:, to: '', groups: nil, scope_names: [], **options) # rubocop:disable Metrics/ParameterLists
        @name = name.to_s.camelize(:lower)
        @module_name = options[:module].to_s
        @function = options[:function]
        @groups = groups
        @relative_path = to
        @on = on.to_sym
        @scope_names = scope_names
      end

      def path
        return relative_path if module_name.empty?

        [module_name, relative_path].join('/')
      end

      def collection?
        on == :collection
      end

      def show_in_group?(group_name)
        return true if groups.nil? || groups.empty?

        groups.include?(group_name&.to_sym)
      end

      def field_options
        if function
          { function: function }
        else
          { resolver: resolver, extras: [:lookahead], **resolver_options }
        end
      end

      private

      attr_reader :function

      def resolver
        @resolver ||= Controller::BuildControllerActionResolver.call(action: action)
      end

      def action
        @action ||= Controller::Action.new(self).tap(&:return_type)
      end

      def resolver_options
        action_config = action.action_config
        action_config.pagination_options || {}
      end
    end
  end
end
