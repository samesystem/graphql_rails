# frozen_string_literal: true

module GraphqlRails
  # attributes namespace
  module Attributes
    require_relative './attributes/attributable'
    require_relative './attributes/attribute'
    require_relative './attributes/input_attribute'

    require_relative './attributes/type_parser'
    require_relative './attributes/attribute_name_parser'
  end
end
