require 'ceres/structure'

module Ceres
  class Enum < Ceres::Structure
    singleton_class.include Enumerable

    def self.inherited(klass)
      klass.instance_variable_set(:@_enum, {})
    end

    def self.value(name, *arguments, &block)
      value = new(*arguments, &block)

      @_enum[name] = value

      define_singleton_method(name) { value }
      define_method("#{name}?") { self.equal?(value) }
    end

    def self.each(&block)
      @_enum.each_value(&block)
    end

    def self.values
      @_enum.values
    end

    def self.to_h
      @_enum
    end
  end
end