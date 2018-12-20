# frozen_string_literal: true

module GraphqlRails
  class Controller
    # stores information about controller filter
    class ActionFilter
      attr_reader :name

      def initialize(name, only: [], except: [])
        @name = name
        @only_actions = Array(only).map(&:to_sym)
        @except_actions = Array(except).map(&:to_sym)
      end

      def applicable_for?(action_name)
        if only_actions.any?
          only_actions.include?(action_name.to_sym)
        elsif except_actions.any?
          !except_actions.include?(action_name.to_sym)
        else
          true
        end
      end

      private

      attr_reader :only_actions, :except_actions
    end
  end
end
