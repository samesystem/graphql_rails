# frozen_string_literal: true

require_relative '../controller/controller_function'

module GraphqlRails
  class Router
    # Generic class for any type graphql action. Should not be used directly
    class Route
      attr_reader :name, :module_name, :on

      def initialize(name, to:, on:, **options)
        @name = name.to_s.camelize(:lower)
        @module_name = options[:module].to_s
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

      def member?
        on == :member
      end

      def options
        { function: Controller::ControllerFunction.build(path) }
      end

      private

      attr_reader :relative_path
    end
  end
end
