# frozen_string_literal: true

require_relative 'action'

module Graphiti
  class Router
    # stores mutation type graphql action info
    class MutationAction < Action
      def query?
        false
      end

      def mutation?
        true
      end
    end
  end
end
