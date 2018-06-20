module Ceres
  class Reader
    attr_reader :attribute
    attr_reader :block

    def initialize(attribute, cache: false, &block)
      @attribute = attribute
      @cache = cache
      @block = block
    end

    def cache?
      @cache
    end

    def name
      @attribute.name
    end

    def target
      @attribute.target
    end

    def variable
      @attribute.variable
    end

    def to_proc
      self.cache? ? to_cached_proc : to_uncached_proc
    end

    def apply(klass)
      name = self.name

      if allow_reader_optimisation?
        klass.instance_exec { attr_reader name }
      else
        reader = self.to_proc

        klass.instance_exec { define_method(name, &reader) }
      end
    end

    private def allow_reader_optimisation?
      !@block && self.target.nil? && self.variable == "@#{self.name}".to_sym
    end

    private def to_uncached_proc
      target = self.target
      variable = self.variable
      block = self.block

      if target
        if block
          proc { instance_variable_get(target).instance_exec(&block) }
        else
          proc { instance_variable_get(target).instance_variable_get(variable) }
        end
      else
        block || proc { instance_variable_get(variable) }
      end
    end

    private def to_cached_proc
      uncached_proc = to_uncached_proc
      variable = self.variable

      proc do
        if instance_variable_defined?(variable)
          instance_variable_get(variable)
        else
          instance_variable_set(variable, instance_exec(&uncached_proc))
        end
      end
    end
  end
end
