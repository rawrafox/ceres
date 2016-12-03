# frozen_string_literal: true

require "ceres/structure"

module Ceres
  class Enum < Ceres::Structure
    singleton_class.instance_eval do
      include Enumerable
      extend Forwardable

      def_delegators :@_enum, :count, :fetch, :keys, :size, :values
    end

    def self.value(name, *arguments, &block)
      value = new(*arguments)

      if @_enum.key?(name)
        raise ArgumentError, "key #{name} already in use"
      else
        @_enum[name] = value
      end

      value.instance_eval(&block) if block_given?

      define_singleton_method(name) { value }
      define_method("#{name}?") { self.equal?(value) }
    end

    def self.each(&block)
      @_enum.each_value(&block)
    end

    def self.to_a
      @_enum.values
    end

    def self.to_h
      @_enum
    end
  end

  # Ruby internals
  class Enum
    private_class_method def self.inherited(child)
      super

      child.instance_variable_set(:@_enum, {})
    end

    private_class_method :new
  end
end
