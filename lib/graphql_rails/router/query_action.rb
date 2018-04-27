# frozen_string_literal: true

require_relative 'action'

module GraphqlRails
  class Router
    # stores query type graphql action info
    class QueryAction < Action
      def query?
        true
      end

      def mutation?
        false
      end
    end
  end
end
