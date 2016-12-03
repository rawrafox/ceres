# frozen_string_literal: true

module Ceres
  module Module
    def after_initialize(&block)
      if instance_variable_defined?(:@_after_initialize)
        raise ArgumentError, "multiple `after_initialize` blocks"
      end

      @_after_initialize = block
    end

    def after_include(&block)
      if instance_variable_defined?(:@_after_include)
        raise ArgumentError, "multiple `after_include` blocks"
      end

      @_after_include = block
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

    private def append_features(base) #:nodoc:
      add_features(base) { super }
    end

    private def prepend_features(_) #:nodoc:
      raise NotImplementedError, "prepend is not implemented"
    end

    private def add_features(base) #:nodoc:
      if base.instance_variable_defined?(:@_module_dependencies)
        base.instance_variable_get(:@_module_dependencies) << self

        return false
      else
        return false if base < self

        @_module_dependencies.each { |dep| base.include(dep) }

        yield

        base.extend const_get(:ClassMethods) if const_defined?(:ClassMethods)

        if instance_variable_defined?(:@_after_include)
          base.class_eval(&@_after_include)
        end

        if instance_variable_defined?(:@_after_initialize)
          list = if base.instance_variable_defined?(:@_after_initialize)
            base.instance_variable_get(:@_after_initialize)
          else
            []
          end

          if list.count.zero?
            base.class_eval do
              def self.new(*args)
                super.tap do |obj|
                  @_after_initialize.each { |block| obj.instance_eval(&block) }
                end
              end
            end
          end

          list << @_after_initialize
          base.instance_variable_set(:@_after_initialize, list)
        end
      end
    end
  end
end
