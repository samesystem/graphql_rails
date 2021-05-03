# frozen_string_literal: true

require 'graphql_rails/model/configuration'

module GraphqlRails
  # this module allows to convert any ruby class in to graphql type object
  #
  # usage:
  # class YourModel
  #   include GraphqlRails::Model
  #
  #   graphql do
  #     attribute :id
  #     attribute :title
  #   end
  # end
  #
  # YourModel.new.graphql_type # => type with [:id, :title] attributes
  module Model
    # static methods for GraphqlRails::Model
    module ClassMethods
      def inherited(subclass)
        super
        subclass.instance_variable_set(:@graphql, graphql.dup)
        subclass.graphql.instance_variable_set(:@model_class, self)
        subclass.graphql.instance_variable_set(:@graphql_type, nil)
      end

      def graphql
        @graphql ||= Model::Configuration.new(self)
        @graphql.tap { |it| yield(it) }.with_ensured_fields! if block_given?
        @graphql
      end
    end

    def self.included(base)
      base.extend(ClassMethods)
    end

    def graphql_context
      @graphql_context
    end

    def graphql_context=(value)
      @graphql_context = value
    end

    def with_graphql_context(graphql_context)
      self.graphql_context = graphql_context
      yield(self)
    ensure
      self.graphql_context = nil
    end
  end
end
