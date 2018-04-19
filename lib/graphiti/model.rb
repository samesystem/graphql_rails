# frozen_string_literal: true

require_relative 'model/configuration'

module Graphiti
  # this module allows to convert any ruby class in to grapql type object
  #
  # usage:
  # class YourModel
  #   include Graphiti::Model
  #
  #   graphiti do
  #     attribute :id
  #     attribute :title
  #   end
  # end
  #
  # YourModel.new.grapql_type # => type with [:id, :title] attributes
  module Model
    def self.included(base)
      base.extend(ClassMethods)
    end

    # static methods for Graphiti::Model
    module ClassMethods
      def graphiti
        @graphiti ||= Model::Configuration.new(self)
        yield(@graphiti) if block_given?
        @graphiti
      end
    end
  end
end
