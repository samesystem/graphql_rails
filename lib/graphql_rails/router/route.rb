# frozen_string_literal: true

require_relative '../controller/build_controller_action_resolver'

module GraphqlRails
  class Router
    # Generic class for any type graphql action. Should not be used directly
    class Route
      attr_reader :name, :module_name, :on, :relative_path, :groups

      def initialize(name, to: '', on:, groups: nil, **options)
        @name = name.to_s.camelize(:lower)
        @module_name = options[:module].to_s
        @function = options[:function]
        @groups = groups
        @relative_path = to
        @on = on.to_sym
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
          { resolver: resolver }
        end
      end

      private

      attr_reader :function

      def resolver
        @resolver ||= Controller::BuildControllerActionResolver.call(route: self)
      end
    end
  end
end
