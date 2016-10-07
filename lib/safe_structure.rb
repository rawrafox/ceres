class SafeStructure
  VERSION = '0.1.0'

  def initialize(values = {})
    @safe_structure_values = {}

    attributes = self.class.attributes

    values.each do |key, _|
      unless attributes.has_key?(key)
        raise ArgumentError, "unknown attribute #{key}"
      end
    end

    attributes.each do |key, options|
      send(options[:setter], values.fetch(key) { options[:default] })
    end
  end

  def self.inherited(base)
    base.instance_variable_set(:@safe_structure_attributes, {})
  end

  def self.define_attribute(name, kind, options)
    # TODO: Remove this requirement by invalidating
    #       @safe_structure_attributes of all subclasses
    if @safe_structure_finalized
      raise ArgumentError, 'safe structure is already finalized'
    end

    if @safe_structure_attributes.has_key?(name)
      raise ArgumentError, 'attribute already defined'
    end

    attribute = {
      kind: kind,
      name: name,
      class: self,
      getter: name,
      setter: "#{name}=".to_sym,
    }.merge(options)

    @safe_structure_attributes[name] = attribute

    define_method(attribute[:getter]) do
      @safe_structure_values[name]
    end

    define_method(attribute[:setter]) do |value|
      value.freeze if attribute[:freeze]

      if attribute[:type] && !value.is_a?(attribute[:type])
        raise ArgumentError, "#{value.inspect} is not of type #{attribute[:type].name}"
      end

      if attribute[:enum] && !attribute[:enum].include?(value)
        raise ArgumentError, "#{value.inspect} is not one of #{attribute[:enum].map(&:inspect).join(', ')}"
      end

      if attribute[:element_type] && !value.all? { |x| x.is_a?(attribute[:element_type]) }
        raise ArgumentError, "#{value.inspect} has elements of other type than #{attribute[:element_type]}"
      end

      @safe_structure_values[name] = value
    end

    private attribute[:setter]
  end

  def self.attribute(name, type: nil, enum: nil, default: nil, optional: false, freeze: true)
    define_attribute(name, :attribute, type: type, enum: enum, default: default, optional: optional, freeze: freeze)
  end

  def self.array(name, type: Array, element_type: nil, enum: nil, default: nil, optional: false, freeze: true)
    define_attribute(name, :array, type: type, element_type: element_type, enum: enum, default: default, optional: optional, freeze: freeze)
  end

  def self.attributes
    @safe_structure_cached_attributes ||= begin
      @safe_structure_finalized = true

      superclass = self.superclass

      if superclass < SafeStructure
        superclass_attributes = superclass.attributes

        keys = (superclass_attributes.keys + @safe_structure_attributes.keys).uniq

        keys.map do |key|
          class_value = @safe_structure_attributes[key] || {}
          superclass_value = superclass_attributes[key] || {}

          [key, superclass_value.merge(class_value)]
        end.to_h
      else
        @safe_structure_attributes
      end
    end
  end
end
