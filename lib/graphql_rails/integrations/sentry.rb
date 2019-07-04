# frozen_string_literal: true

module GraphqlRails
  module Integrations
    # sentry integration
    module Sentry
      require 'active_support/concern'

      # controller extension which logs errors to sentry
      module SentryLogger
        extend ActiveSupport::Concern

        included do
          around_action :log_to_sentry

          protected

          def log_to_sentry
            Raven.context.transaction.pop
            Raven.context.transaction.push "#{self.class}##{action_name}"
            yield
          rescue Exception => error # rubocop:disable Lint/RescueException
            Raven.capture_exception(error) unless error.is_a?(GraphQL::ExecutionError)
            raise error
          end
        end
      end

      def self.enable
        GraphqlRails::Controller.include(SentryLogger)
      end
    end
  end
end
