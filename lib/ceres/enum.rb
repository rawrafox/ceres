# frozen_string_literal: true

require "ceres/structure"

module Ceres
  class Enum < Ceres::Structure
    singleton_class.include Enumerable

    def self.inherited(klass)
      klass.instance_variable_set(:@_enum, {})
    end

    def self.value(name, *arguments, &block)
      value = new(*arguments, &block)

      if @_enum.key?(name)
        raise ArgumentError, "key #{name} already in use"
      else
        @_enum[name] = value
      end

      define_singleton_method(name) { value }
      define_method("#{name}?") { self.equal?(value) }
    end

    def self.each(&block)
      @_enum.each_value(&block)
    end

    def self.keys
      @_enum.keys
    end

    def self.values
      @_enum.values
    end

    def self.to_h
      @_enum
    end
  end
end
