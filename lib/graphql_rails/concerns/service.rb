# frozen_string_literal: true

module GraphqlRails
  # includes all service object related logic
  module Service
    require 'active_support/concern'
    extend ActiveSupport::Concern

    class_methods do
      def call(*args, **kwargs, &block)
        new(*args, **kwargs).call(&block)
      end
    end
  end
end
