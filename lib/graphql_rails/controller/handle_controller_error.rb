# frozen_string_literal: true

module GraphqlRails
  class Controller
    # runs {before/around/after}_action controller hooks
    class HandleControllerError
      def initialize(error:, controller:)
        @error = error
        @controller = controller
      end

      def call
        return custom_handle_error if custom_handle_error?

        render_unhandled_error(error)
      end

      private

      attr_reader :error, :controller

      def render_unhandled_error(error)
        return render(error: error) if error.is_a?(GraphQL::ExecutionError)

        render(error: SystemError.new(error))
      end

      def custom_handle_error
        return unless custom_handler

        begin
          if custom_handler.is_a?(Proc)
            controller.instance_exec(error, &custom_handler)
          else
            controller.send(custom_handler)
          end
        rescue StandardError => e
          render_unhandled_error(e)
        end
      end

      def custom_handler
        return @custom_handler if defined?(@custom_handler)

        handler = controller_config.error_handlers.detect do |error_class, _handler|
          error.class <= error_class
        end

        @custom_handler = handler&.last
      end

      def custom_handle_error?
        custom_handler.present?
      end

      def controller_config
        @controller_config ||= controller.class.controller_configuration
      end

      def render(*args, **kwargs, &block)
        controller.send(:render, *args, **kwargs, &block)
      end
    end
  end
end
