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
      def decorate(object, *args, build_with: :new, **kwargs)
        if Decorator::RelationDecorator.decorates?(object)
          decorate_with_relation_decorator(object, args, kwargs, build_with: build_with)
        elsif object.nil?
          nil
        elsif object.is_a?(Array)
          object.map { |item| public_send(build_with, item, *args, **kwargs) }
        else
          public_send(build_with, object, *args, **kwargs)
        end
      end

      private

      def decorate_with_relation_decorator(object, args, kwargs, build_with:)
        Decorator::RelationDecorator.new(
          relation: object,
          decorator: self,
          decorator_args: args,
          decorator_kwargs: kwargs,
          build_with: build_with
        )
      end
    end
  end
end
