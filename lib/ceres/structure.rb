# frozen_string_literal: true

module Ceres
  class Structure
    def initialize(values = {})
      @_structure_values = {}

      attributes = self.class.attributes

      values.each do |key, _|
        unless attributes.key?(key)
          raise ArgumentError, "unknown attribute #{key}"
        end
      end

      attributes.each do |key, options|
        send(options[:setter], values.fetch(key) { options[:default] })
      end
    end

    def self.attribute(name, type: nil, enum: nil, default: nil, optional: false, freeze: true)
      options = {
        type: type,
        enum: enum,
        default: default,
        optional: optional,
        freeze: freeze
      }

      define_attribute(name, :attribute, options)
    end

    def self.array(name,
                   type: Array,
                   element_type: nil,
                   enum: nil,
                   default: nil,
                   optional: false,
                   freeze: true)
      options = {
        type: type,
        element_type: element_type,
        enum: enum,
        default: default,
        optional: optional,
        freeze: freeze
      }

      define_attribute(name, :array, options)
    end

    def self.attributes
      @_structure_cached_attributes ||= begin
        @_structure_finalized = true
        @_structure_attributes ||= {}

        superclass = self.superclass

        if superclass < Ceres::Structure
          superclass_attributes = superclass.attributes

          keys = (superclass_attributes.keys + @_structure_attributes.keys).uniq

          keys.map do |key|
            class_value = @_structure_attributes[key] || {}
            superclass_value = superclass_attributes[key] || {}

            [key, superclass_value.merge(class_value)]
          end.to_h
        else
          @_structure_attributes
        end
      end
    end

    def self.equality(*attributes, eq: nil, eql: true, hash: true)
      raise ArgumentError, "need to provide at least one attribute" unless attributes.count > 0

      @_structure_ordered ||= false

      if eq && @_structure_ordered
        raise ArgumentError, "asking to overwrite `==` from order, probably not what you want"
      end

      define_eq(:==, attributes: attributes) if eq.nil? || eq
      define_eq(:eql?, attributes: attributes) if eql
      define_hash(:hash, attributes: attributes) if hash
    end

    def self.order(*attributes)
      raise ArgumentError, "need to provide at least one attribute" unless attributes.count > 0

      @_structure_ordered = true

      define_method(:<=>) do |other|
        raise ArgumentError, "not of the same class" unless self.class == other.class

        self_attributes = attributes.map { |attribute| self.public_send(attribute) }
        other_attributes = attributes.map { |attribute| other.public_send(attribute) }

        self_attributes <=> other_attributes
      end

      include Comparable
    end

    private_class_method def self.define_attribute(name, kind, options)
      # TODO: Remove this requirement by invalidating @_structure_attributes of all subclasses
      @_structure_finalized ||= false

      raise ArgumentError, "safe structure is already finalized" if @_structure_finalized

      @_structure_attributes ||= {}

      raise ArgumentError, "attribute already defined" if @_structure_attributes.key?(name)

      attribute = {
        kind: kind,
        name: name,
        class: self,
        getter: name,
        setter: "#{name}=".to_sym,
        public_getter: true,
        public_setter: false
      }.merge(options)

      @_structure_attributes[name] = attribute

      define_getter(attribute)
      define_setter(attribute)

      attribute[:getter]
    end

    private_class_method def self.define_eq(name, attributes:)
      define_method(name) do |other|
        return false unless self.class == other.class

        attributes.all? do |attribute|
          self.public_send(attribute).public_send(name, other.public_send(attribute))
        end
      end
    end

    private_class_method def self.define_hash(name, attributes:)
      define_method(name) do
        self.class.public_send(name) ^ attributes.map(&name).reduce(&:"^")
      end
    end

    private_class_method def self.define_getter(attribute)
      name = attribute[:name]

      define_method(attribute[:getter]) do
        @_structure_values.fetch(name)
      end

      private attribute[:getter] unless attribute[:public_getter]
    end

    private_class_method def self.define_setter(attribute)
      name = attribute[:name]

      define_method(attribute[:setter]) do |value|
        value.freeze if attribute[:freeze]

        if attribute[:type] && !value.is_a?(attribute[:type])
          raise ArgumentError, "attribute #{attribute[:name]} (#{value.inspect}) is not of type " \
                               "#{attribute[:type].name}"
        end

        if attribute[:enum] && !attribute[:enum].include?(value)
          raise ArgumentError, "attribute #{attribute[:name]} (#{value.inspect}) is not one of " \
                               "#{attribute[:enum].map(&:inspect).join(', ')}"
        end

        if attribute[:element_type] && !value.all? { |x| x.is_a?(attribute[:element_type]) }
          raise ArgumentError, "attribute #{attribute[:name]} (#{value.inspect}) has elements of " \
                               "other type than #{attribute[:element_type]}"
        end

        @_structure_values[name] = value
      end

      private attribute[:setter] unless attribute[:public_setter]
    end
  end
end
