module Ceres
  class Writer
    attr_reader :attribute
    attr_reader :block

    def initialize(attribute, &block)
      @attribute = attribute
      @block = block
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
      target = self.target
      variable = self.variable
      block = self.block

      if target
        if block
          proc do |v|
            t = instance_variable_get(target)
            t.instance_variable_set(variable, t.instance_exec(v, &block))
          end
        else
          proc { |v| instance_variable_get(target).instance_variable_set(variable, v) }
        end
      else
        if block
          proc { |v| instance_variable_set(variable, instance_exec(v, &block)) }
        else
          proc { |v| instance_variable_set(variable, v) }
        end
      end
    end

    def apply(klass)
      if allow_writer_optimisation?
        name = self.name

        klass.instance_exec { attr_writer name }
      else
        name = "#{@attribute.name}=".to_sym
        writer = self.to_proc

        klass.instance_exec { define_method(name, &writer) }
      end
    end

    private def allow_writer_optimisation?
      !@block && self.target.nil? && self.variable == "@#{@attribute.name}".to_sym
    end
  end
end
