# frozen_string_literal: true

module GraphqlRails
  class Controller
    # stores information about controller hooks like before_action, after_action, etc.
    class ActionHook
      attr_reader :name, :action_proc

      def initialize(name: nil, only: [], except: [], &action_proc)
        @name = name
        @action_proc = action_proc
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

      def anonymous?
        !!action_proc # rubocop:disable Style/DoubleNegation
      end

      private

      attr_reader :only_actions, :except_actions
    end
  end
end
