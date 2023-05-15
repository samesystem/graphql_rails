# frozen_string_literal: true

require_relative 'route'

module GraphqlRails
  class Router
    # stores query type graphql action info
    class QueryRoute < Route
      def query?
        true
      end

      def mutation?
        false
      end

      def event?
        false
      end
    end
  end
end
