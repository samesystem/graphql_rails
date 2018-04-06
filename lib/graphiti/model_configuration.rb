# frozen_string_literal: true

require_relative 'model_configuration/attributes'

module Graphiti
  class ModelConfiguration
    attr_reader :attributes

    def initialize
      @attributes = Attributes.new
    end

    def attribute(attribute_name, type = nil)
      attributes.add(attribute_name, type)
    end
  end
end
