# frozen_string_literal: true

require 'graphql_rails/errors/execution_error'

module GraphqlRails
  class Controller
    # logs controller start and end times
    class LogControllerAction
      require 'graphql_rails/concerns/service'
      require 'active_support/notifications'

      include ::GraphqlRails::Service

      START_PROCESSING_KEY = 'start_processing.graphql_action_controller'
      PROCESS_ACTION_KEY = 'process_action.graphql_action_controller'

      def initialize(controller_name:, action_name:, params:, graphql_request:)
        @controller_name = controller_name
        @action_name = action_name
        @params = params
        @graphql_request = graphql_request
      end

      def call
        ActiveSupport::Notifications.instrument(START_PROCESSING_KEY, default_payload)
        ActiveSupport::Notifications.instrument(PROCESS_ACTION_KEY, default_payload) do |payload|
          yield.tap do
            payload[:status] = status
          end
        end
      end

      private

      attr_reader :controller_name, :action_name, :params, :graphql_request

      def default_payload
        {
          controller: controller_name,
          action: action_name,
          params: filtered_params
        }
      end

      def status
        graphql_request.errors.present? ? 500 : 200
      end

      def filtered_params
        @filtered_params ||=
          if filter_parameters.empty?
            params
          else
            filter_options = Rails.configuration.filter_parameters
            parameter_filter_class.new(filter_options).filter(params)
          end
      end

      def filter_parameters
        return [] if !defined?(Rails) || Rails.application.nil?

        Rails.application.config.filter_parameters || []
      end

      def parameter_filter_class
        if ActiveSupport.gem_version.segments.first < 6
          return ActiveSupport::ParameterFilter if Object.const_defined?('ActiveSupport::ParameterFilter')

          ActionDispatch::Http::ParameterFilter
        else
          require 'active_support/parameter_filter'
          ActiveSupport::ParameterFilter
        end
      end
    end
  end
end
