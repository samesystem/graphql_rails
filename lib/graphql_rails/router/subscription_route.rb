# frozen_string_literal: true

require_relative 'route'

module GraphqlRails
  class Router
    # stores subscription type graphql action info
    class SubscriptionRoute < Route
      def query?
        false
      end

      def mutation?
        false
      end

      def subscription?
        true
      end
    end
  end
end
