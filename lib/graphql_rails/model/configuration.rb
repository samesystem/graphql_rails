# frozen_string_literal: true

require 'graphql_rails/attribute'

module GraphqlRails
  module Model
    # stores information about model specific config, like attributes and types
    class Configuration
      attr_reader :attributes

      def initialize(model_class)
        @model_class = model_class
        @attributes = {}
      end

      def attribute(attribute_name, type: nil, hidden: false)
        attributes[attribute_name.to_s] = Attribute.new(attribute_name, type, hidden: hidden)
      end

      def include_model_attributes(except: [])
        except = Array(except).map(&:to_s)

        if defined?(Mongoid) && model_class < Mongoid::Document
          assign_default_mongoid_attributes(except: except)
        elsif defined?(ActiveRecord) && model_class < ActiveRecord::Base
          assign_default_active_record_attributes(except: except)
        end
      end

      def graphql_type
        @graphql_type ||= generate_graphql_type(graphql_type_name, visible_attributes)
      end

      private

      attr_reader :model_class

      def visible_attributes
        attributes.reject { |_name, attribute| attribute.hidden? }
      end

      def graphql_type_name
        model_class.name.split('::').last
      end

      def generate_graphql_type(type_name, attributes)
        GraphQL::ObjectType.define do
          name(type_name)
          description("Generated programmatically from model: #{type_name}")

          attributes.each_value do |attribute|
            field(attribute.field_name, attribute.graphql_field_type, property: attribute.name.to_sym)
          end
        end
      end

      def assign_default_mongoid_attributes(except: [])
        allowed_fields = model_class.fields.except('_type', '_id', *except)

        attribute('id', type: 'id')

        allowed_fields.each_value do |field|
          attribute(field.name, type: field.type.to_s.split('::').last)
        end
      end

      def assign_default_active_record_attributes(except: [])
        allowed_fields = model_class.columns.index_by(&:name).except('type', *except)

        allowed_fields.each_value do |field|
          field_type = field.cast_type.class.to_s.downcase.split('::').last
          field_type = 'string' if field_type.ends_with?('string')
          field_type = 'date' if field_type.include?('date')
          field_type = 'time' if field_type.include?('time')

          attribute(field.name, type: field_type.to_s.split('::').last)
        end
      end
    end
  end
end
