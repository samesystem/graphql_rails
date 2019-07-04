# frozen_string_literal: true

module GraphqlRails
  module Integrations
    # lograge integration
    #
    # usage:
    # add `GraphqlRails::Integrations::Lograge.enable` in your initializers
    module Lograge
      require 'lograge'

      # lograge subscriber for graphql_rails controller events
      class GraphqlActionControllerSubscriber < ::Lograge::LogSubscribers::Base
        def process_action(event)
          process_main_event(event)
        end

        private

        def initial_data(payload)
          {
            controller: payload[:controller],
            action: payload[:action]
          }
        end
      end

      def self.enable
        return unless active?

        GraphqlActionControllerSubscriber.attach_to :graphql_action_controller
      end

      def self.active?
        !defined?(Rails) || Rails.configuration&.lograge&.enabled
      end
    end
  end
end
