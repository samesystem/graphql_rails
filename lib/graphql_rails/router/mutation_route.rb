# frozen_string_literal: true

require_relative 'route'

module GraphqlRails
  class Router
    # stores mutation type graphql action info
    class MutationRoute < Route
      def query?
        false
      end

      def mutation?
        true
      end

      def event?
        false
      end
    end
  end
end
