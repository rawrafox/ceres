# frozen_string_literal: true

module Ceres
  module Module
    def on_initialize(&block)
      if instance_variable_defined?(:@_on_initialize)
        raise ArgumentError, "multiple `on_initialize` blocks"
      end

      @_on_initialize = block
    end

    def on_include(&block)
      if instance_variable_defined?(:@_on_include)
        raise ArgumentError, "multiple `on_include` blocks"
      end

      @_on_include = block
    end

    def class_methods(&block)
      mod = if const_defined?(:ClassMethods, false)
        const_get(:ClassMethods)
      else
        const_set(:ClassMethods, ::Module.new)
      end

      mod.module_eval(&block)
    end

    def self.extended(base) #:nodoc:
      base.instance_variable_set(:@_module_dependencies, [])
    end

    def add_features(base) #:nodoc:
      if base.instance_variable_defined?(:@_module_dependencies)
        base.instance_variable_get(:@_module_dependencies) << self

        return false
      else
        return false if base < self

        @_module_dependencies.each { |dep| base.include(dep) }

        yield

        base.extend const_get(:ClassMethods) if const_defined?(:ClassMethods)

        if instance_variable_defined?(:@_on_include)
          base.class_eval(&@_on_include)
        end

        if instance_variable_defined?(:@_on_initialize)
          list = if base.instance_variable_defined?(:@_on_initialize)
            base.instance_variable_get(:@_on_initialize)
          else
            []
          end

          if list.count.zero?
            base.class_eval do
              def self.new(*args)
                super.tap do |obj|
                  @_on_initialize.each { |block| obj.instance_eval(&block) }
                end
              end
            end
          end

          list << @_on_initialize
          base.instance_variable_set(:@_on_initialize, list)
        end
      end
    end

    def append_features(base) #:nodoc:
      add_features(base) { super }
    end

    def prepend_features(base) #:nodoc:
      add_features(base) { super }
    end
  end
end
