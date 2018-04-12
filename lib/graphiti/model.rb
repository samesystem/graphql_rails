# frozen_string_literal: true

require_relative 'model/configuration'

module Graphiti
  module Model
    def self.included(base)
      base.extend(ClassMethods)
    end

    module ClassMethods
      def graphiti
        @graphiti ||= Model::Configuration.new(self)
        yield(@graphiti) if block_given?
        @graphiti
      end
    end
  end
end
