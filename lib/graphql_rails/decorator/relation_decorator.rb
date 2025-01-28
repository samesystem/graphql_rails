# frozen_string_literal: true

module GraphqlRails
  module Decorator
    # wraps active record relation and returns decorated object instead
    class RelationDecorator
      delegate :map, :each, to: :to_a
      delegate :limit_value, :offset_value, :count, :size, :empty?, :loaded?, to: :relation

      def self.decorates?(object)
        (defined?(ActiveRecord) && object.is_a?(ActiveRecord::Relation)) ||
          defined?(Mongoid) && object.is_a?(Mongoid::Criteria)
      end

      def initialize(decorator:, relation:, decorator_args: [], decorator_kwargs: {}, build_with: :new)
        @relation = relation
        @decorator = decorator
        @decorator_args = decorator_args
        @decorator_kwargs = decorator_kwargs
        @build_with = build_with
      end

      %i[where limit order group offset from select having all unscope].each do |method_name|
        define_method method_name do |*args, **kwargs, &block|
          chainable_method(method_name, *args, **kwargs, &block)
        end
      end

      %i[first second last find find_by].each do |method_name|
        define_method method_name do |*args, **kwargs, &block|
          decoratable_object_method(method_name, *args, **kwargs, &block)
        end
      end

      %i[find_each].each do |method_name|
        define_method method_name do |*args, **kwargs, &block|
          decoratable_block_method(method_name, *args, **kwargs, &block)
        end
      end

      def to_a
        @to_a ||= relation.to_a.map { |it| build_decorator(it, *decorator_args, **decorator_kwargs) }
      end

      private

      attr_reader :relation, :decorator, :decorator_args, :decorator_kwargs, :build_with

      def decoratable_object_method(method_name, *args, **kwargs, &block)
        object = relation.public_send(method_name, *args, **kwargs, &block)
        decorate(object)
      end

      def decorate(object_or_list)
        return object_or_list if object_or_list.blank?

        if object_or_list.is_a?(Array)
          object_or_list.map { |it| build_decorator(it, *decorator_args, **decorator_kwargs) }
        else
          build_decorator(object_or_list, *decorator_args, **decorator_kwargs)
        end
      end

      def build_decorator(*args, **kwargs, &block)
        decorator.public_send(build_with, *args, **kwargs, &block)
      end

      def decoratable_block_method(method_name, *args, **kwargs)
        relation.public_send(method_name, *args, **kwargs) do |object, *other_args|
          decorated_object = decorate(object)
          yield(decorated_object, *other_args)
        end
      end

      def chainable_method(method_name, *args, **kwargs, &block)
        new_relation = relation.public_send(method_name, *args, **kwargs, &block)
        self.class.new(
          decorator: decorator, relation: new_relation,
          decorator_args: decorator_args, decorator_kwargs: decorator_kwargs,
          build_with: build_with
        )
      end
    end
  end
end
