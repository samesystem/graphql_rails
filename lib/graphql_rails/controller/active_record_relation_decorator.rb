# frozen_string_literal: true

module GraphqlRails
  class Controller
    # wrapps active record relation and returns decorated object instead
    class ActiveRecordRelationDecorator
      delegate :map, :each, to: :to_a
      delegate :limit_value, :offset_value, :count, :size, to: :relation

      def initialize(decorator:, relation:)
        @relation = relation
        @decorator = decorator
      end

      %i[where limit order group offset from select having all unscope].each do |method_name|
        define_method method_name do |*args, &block|
          chainable_method(method_name, *args, &block)
        end
      end

      %i[first second last].each do |method_name|
        define_method method_name do |*args, &block|
          decoratable_object_method(method_name, *args, &block)
        end
      end

      %i[find_each].each do |method_name|
        define_method method_name do |*args, &block|
          decoratable_block_method(method_name, *args, &block)
        end
      end

      def to_a
        @to_a ||= relation.to_a.map { |it| decorator.new(it) }
      end

      private

      attr_reader :relation, :decorator

      def decoratable_object_method(method_name, *args, &block)
        object = relation.public_send(method_name, *args, &block)
        decorate(object)
      end

      def decorate(object_or_list)
        return object_or_list if object_or_list.blank?

        if object_or_list.is_a?(Array)
          object_or_list.map { |it| decorator.new(it) }
        else
          decorator.new(object_or_list)
        end
      end

      def decoratable_block_method(method_name, *args)
        relation.public_send(method_name, *args) do |object, *other_args|
          decorated_object = decorate(object)
          yield(decorated_object, *other_args)
        end
      end

      def chainable_method(method_name, *args, &block)
        new_relation = relation.public_send(method_name, *args, &block)
        self.class.new(decorator: decorator, relation: new_relation)
      end
    end
  end
end
