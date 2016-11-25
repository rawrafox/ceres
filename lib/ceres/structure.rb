# frozen_string_literal: true

module Ceres
  class Structure
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

    def self.define_attribute(name, kind, options)
      # TODO: Remove this requirement by invalidating
      #       @safe_structure_attributes of all subclasses
      @safe_structure_finalized ||= false

      if @safe_structure_finalized
        raise ArgumentError, 'safe structure is already finalized'
      end

      @safe_structure_attributes ||= {}

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
          raise ArgumentError, "attribute #{attribute[:name]} (#{value.inspect}) is not of type #{attribute[:type].name}"
        end

        if attribute[:enum] && !attribute[:enum].include?(value)
          raise ArgumentError, "attribute #{attribute[:name]} (#{value.inspect}) is not one of #{attribute[:enum].map(&:inspect).join(', ')}"
        end

        if attribute[:element_type] && !value.all? { |x| x.is_a?(attribute[:element_type]) }
          raise ArgumentError, "attribute #{attribute[:name]} (#{value.inspect}) has elements of other type than #{attribute[:element_type]}"
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
        @safe_structure_attributes ||= {}

        superclass = self.superclass

        if superclass < Ceres::Structure
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

    def self.equality(*attributes, eq: nil, eql: true, hash: true)
      raise ArgumentError, 'need to provide at least one attribute' unless attributes.count > 0

      @safe_structure_ordered ||= false

      if eq && @safe_structure_ordered
        raise ArgumentError, 'asking to overwrite `==` from order, probably not what you want'
      elsif eq != false
        define_method(:==) do |other|
          return false unless self.class == other.class

          attributes.all? { |attribute| self.public_send(attribute) == other.public_send(attribute) }
        end
      end

      if eql
        define_method(:eql?) do |other|
          return false unless self.class == other.class

          attributes.all? { |attribute| self.public_send(attribute) == other.public_send(attribute) }
        end
      end

      if hash
        define_method(:hash) do
         self.class.hash ^ attributes.map(&:hash).reduce(&:'^')
        end
      end
    end

    def self.order(*attributes)
      raise ArgumentError, 'need to provide at least one attribute' unless attributes.count > 0

      @safe_structure_ordered = true

      define_method(:<=>) do |other|
        raise ArgumentError, 'not of the same class' unless self.class == other.class

        self_attributes = attributes.map { |attribute| self.public_send(attribute) }
        other_attributes = attributes.map { |attribute| other.public_send(attribute) }

        self_attributes <=> other_attributes
      end

      include Comparable
    end
  end
end
