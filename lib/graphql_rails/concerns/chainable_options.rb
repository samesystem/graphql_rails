# frozen_string_literal: true

module GraphqlRails
  # Allows defining methods chained way
  module ChainableOptions
    NOT_SET = Object.new

    # nodoc
    module ClassMethods
      def chainable_option(option_name, default: nil)
        define_method(option_name) do |value = NOT_SET|
          get_or_set_chainable_option(option_name, value, default: default)
        end
      end
    end

    def self.included(base)
      base.extend(ClassMethods)
    end

    def initialize_copy(other)
      super
      @chainable_option = other.instance_variable_get(:@chainable_option).dup
    end

    def with(**options)
      options.each do |method_name, args|
        send_args = [method_name]
        send_args << args if method(method_name).parameters.present?
        public_send(*send_args)
      end
      self
    end

    private

    def fetch_chainable_option(option_name, *default, &block)
      @chainable_option.fetch(option_name.to_sym, *default, &block)
    end

    def get_or_set_chainable_option(option_name, value = NOT_SET, default: nil)
      @chainable_option ||= {}
      return fetch_chainable_option(option_name, default) if value == NOT_SET

      @chainable_option[option_name.to_sym] = value
      self
    end
  end
end
