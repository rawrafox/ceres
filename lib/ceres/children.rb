require "ceres/attribute"

module Ceres
  module Children
    include Ceres::AttributeModule
    include Enumerable

    attribute :children do
      reader { @children.values }
    end

    def initialize(*args, &block)
      super(*args, &block)

      @children = {}
    end

    private def child_key_from_object(object)
      object.name
    end

    private def child_value_from_object(object)
      object
    end

    def add_child(child, replace: false)
      key = child_key_from_object(child)

      if replace || !@children.has_key?(key)
        @children[key] = child_value_from_object(child)
      else
        message = "overwriting #{key.inspect} is not allowed"
        message += "\n  new value: #{child.inspect}"
        message += "\n  old value: #{@children[key].inspect}"

        raise ArgumentError, message
      end
    end

    def remove_child(key, &block)
      if result = @children.delete(key)
        result
      elsif block
        block.call(key)
      else
        raise KeyError.new("key not found #{key.inspect}")

        # TODO (ruby 2.6)
        # raise KeyError.new("key not found #{key.inspect}", key: name, receiver: self)
      end
    end

    def each_child(&block)
      @children.each_value(&block)

      self
    end

    def select_children(&block)
      @children.values.select(&block)
    end

    def [](key)
      @children[key]
    end

    def has_key?(key)
      @children.has_key?(key)
    end

    def fetch(key, *argv, &block)
      if self.has_key?(key)
        @children[key]
      elsif argv.count > 0
        argv[0]
      elsif block
        block.call(key)
      else
        raise KeyError.new("key not found #{key.inspect}")

        # TODO (ruby 2.6)
        # raise KeyError.new("key not found #{key.inspect}", key: name, receiver: self)
      end
    end

    def fetch_values(*keys, &block)
      keys.map { |k| self.fetch(k, &block) }
    end

    def dig(key, *argv, &block)
      if self.has_key?(key)
        object = self[key]

        argv.count > 0 ? object.dig(*argv) : object
      end
    end
  end
end
