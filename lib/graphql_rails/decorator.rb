# frozen_string_literal: true

module GraphqlRails
  # adds `.decorate` class method to any class. Handy when using with paginated responses
  #
  # usage:
  # class FriendDecorator < SimpleDecorator
  #   include GraphqlRails::Decorator
  #
  #   graphql.attribute :full_name
  # end
  #
  # class User
  #   has_many :friends
  #   graphql.attribute :decorated_friends, paginated: true, type: 'FriendDecorator!'
  #
  #   def decorated_friends
  #     FriendDecorator.decorate(friends)
  #   end
  # end
  module Decorator
    require 'active_support/concern'
    require 'graphql_rails/decorator/relation_decorator'

    extend ActiveSupport::Concern

    class_methods do
      def decorate(object, *args)
        if Decorator::RelationDecorator.decorates?(object)
          Decorator::RelationDecorator.new(relation: object, decorator: self, decorator_args: args)
        elsif object.nil?
          nil
        elsif object.is_a?(Array)
          object.map { |item| new(item, *args) }
        else
          new(object, *args)
        end
      end
    end
  end
end
