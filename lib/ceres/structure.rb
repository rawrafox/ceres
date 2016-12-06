# frozen_string_literal: true

require "ceres/refinements/enumeration"
require "ceres/refinements/object"

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

      self.class.send(:after_initialize_blocks).each { |block| self.instance_eval(&block) }
    end

    def self.after_initialize(&block)
      @_structure_after_initialize << block
    end

    def self.attribute(name, type: nil, enum: nil, default: nil, optional: false, freeze: true)
      options = { type: type, enum: enum, default: default, optional: optional, freeze: freeze }

      define_attribute(name, :attribute, options)
    end

    def self.array(name,
                   type: ::Array,
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

      define_cmp(:<=>, attributes: attributes)

      include Comparable
    end

    def self.own_attributes
      @_structure_attributes
    end
  end

  # Ruby internals
  class Structure
    private_class_method def self.inherited(child)
      child.instance_variable_set(:@_structure_attributes, {})
      child.instance_variable_set(:@_structure_after_initialize, [])
      child.instance_variable_set(:@_structure_cached_attributes, nil)
      child.instance_variable_set(:@_structure_ordered, false)
    end
  end

  # Ceres internals
  class Structure
    private_class_method def self.after_initialize_blocks
      self.ancestors.flat_map do |ancestor|
        if ancestor.instance_variable_defined?(:@_structure_after_initialize)
          ancestor.instance_variable_get(:@_structure_after_initialize)
        end
      end.compact
    end

    private_class_method def self.define_attribute(name, kind, options)
      Ceres::Object.descendants(self).each do |descendant|
        if descendant.own_attributes.key?(name)
          raise ArgumentError, "attribute already defined in subclass #{descendant}"
        end

        descendant.send(:invalidate_attributes)
      end

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

    private_class_method def self.define_cmp(name, attributes:)
      define_method(name) do |other|
        raise ArgumentError, "not of the same class" unless self.class == other.class

        self_attributes = attributes.map { |attribute| self.public_send(attribute) }
        other_attributes = attributes.map { |attribute| other.public_send(attribute) }

        self_attributes.public_send(name, other_attributes)
      end
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

        args = Ceres::Enumeration.only(attribute, :type, :types, :enum, :element_type)

        Ceres::Verify.verify value, **args

        @_structure_values[name] = value
      end

      private attribute[:setter] unless attribute[:public_setter]
    end

    private_class_method def self.invalidate_attributes
      @_structure_cached_attributes = nil
    end
  end
end
