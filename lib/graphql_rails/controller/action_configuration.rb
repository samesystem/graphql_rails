# frozen_string_literal: true

require 'active_support/core_ext/string/filters'
require 'graphql_rails/attributes'
require 'graphql_rails/input_configurable'
require 'graphql_rails/errors/error'

module GraphqlRails
  class Controller
    # stores all graphql_rails controller specific config
    class ActionConfiguration
      class MissingConfigurationError < GraphqlRails::Error; end
      class DeprecatedDefaultModelError < GraphqlRails::Error; end

      include InputConfigurable

      attr_reader :attributes, :pagination_options, :name, :controller, :defined_at

      def initialize_copy(other)
        super
        @attributes = other.instance_variable_get(:@attributes).dup.transform_values(&:dup)
        @action_options = other.instance_variable_get(:@action_options).dup.transform_values(&:dup)
        @pagination_options = other.instance_variable_get(:@pagination_options)&.dup&.transform_values(&:dup)
      end

      def initialize(name:, controller:)
        @name = name
        @controller = controller
        @attributes = {}
        @action_options = {}
      end

      def dup_with(name:, controller:, defined_at:)
        dup.tap do |new_action|
          new_action.instance_variable_set(:@defined_at, defined_at)
          new_action.instance_variable_set(:@name, name)
          new_action.instance_variable_set(:@controller, controller)
        end
      end

      def options(action_options = nil)
        @input_attribute_options ||= {}
        return @input_attribute_options if action_options.nil?

        @input_attribute_options[:input_format] = action_options[:input_format] if action_options[:input_format]

        self
      end

      def paginated(*args)
        @return_type = nil
        super
      end

      def description(new_description = nil)
        if new_description
          @description = new_description
          self
        else
          @description
        end
      end

      def returns(custom_return_type)
        @return_type = nil
        @custom_return_type = custom_return_type
        self
      end

      def model(model_name = nil)
        if model_name
          @model = model_name
          self
        else
          @model || raise_missing_config_error
        end
      end

      def returns_single(required: true)
        model_name = model.to_s
        model_name = "#{model_name}!" if required

        returns(model_name)
      end

      def returns_list(required_inner: true, required_list: true)
        model_name = model.to_s
        model_name = "#{model_name}!" if required_inner
        list_name = "[#{model_name}]"
        list_name = "#{list_name}!" if required_list

        returns(list_name)
      end

      def return_type
        @return_type ||= build_return_type
      end

      def type_parser
        @type_parser ||= Attributes::TypeParser.new(custom_return_type, paginated: paginated?)
      end

      private

      attr_reader :custom_return_type

      def build_return_type
        return raise_deprecation_error if custom_return_type.nil?

        if paginated?
          type_parser.graphql_model ? type_parser.graphql_model.graphql.connection_type : nil
        else
          type_parser.graphql_type
        end
      end

      def raise_deprecation_error
        message = \
          'Default return types are deprecated. ' \
          "You need to manually set something like `action(:#{name}).returns('#{suggested_model_name}')`"

        full_backtrace = ([defined_at] + caller).compact
        raise DeprecatedDefaultModelError, message, full_backtrace
      end

      def suggested_model_name
        controller&.name.to_s.demodulize.sub(/Controller$/, '').singularize
      end

      def raise_missing_config_error
        error_message = \
          'Default model for controller is not defined. To do so add `model(YourModel)`'

        raise MissingConfigurationError, error_message
      end
    end
  end
end
