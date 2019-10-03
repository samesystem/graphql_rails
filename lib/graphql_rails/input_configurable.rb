module GraphqlRails
  # contains configuration options related with inputs
  module InputConfigurable
    def permit(*no_type_attributes, **typed_attributes)
      no_type_attributes.each { |attribute| permit_input(attribute) }
      typed_attributes.each { |attribute, type| permit_input(attribute, type: type) }
      self
    end

    def permit_input(name, type: nil, options: {}, **input_options)
      field_name = name.to_s.remove(/!\Z/)

      attributes[field_name] = Attributes::InputAttribute.new(
        name.to_s, type,
        options: input_attribute_options.merge(options),
        **input_options
      )
      self
    end

    def paginated(pagination_options = {})
      pagination_options = {} if pagination_options == true
      pagination_options = nil if pagination_options == false

      @pagination_options = pagination_options
      permit(:before, :after, first: :int, last: :int)
    end

    def paginated?
      !pagination_options.nil?
    end

    def pagination_options
      @pagination_options
    end

    def input_attribute_options
      @input_attribute_options || {}
    end

    def build_input_attribute(name, type: nil, description: nil, subtype: nil)
      Attributes::InputAttribute.new(
        name.to_s, type,
        description: description,
        subtype: subtype,
        options: input_attribute_options
      )
    end
  end
end
