require "ceres/attribute"

module Ceres
  class Object
    def self.inherited(klass)
      klass.instance_exec { @attributes = [] }
    end

    def self.attribute(name, &block)
      attribute = Ceres::Attribute.new(name, &block)
      attribute.apply(self)

      @attributes << attribute
    end

    def self.attributes(all: true)
      if all
        self.ancestors.flat_map do |ancestor|
          if ancestor.respond_to?(:attributes)
            ancestor.attributes(all: false)
          else
            []
          end
        end
      elsif defined?(@attributes)
        @attributes
      else
        []
      end
    end

    def inspect
      attributes = self.class.attributes.map do |attribute|
        if attribute.inspector
          name = attribute.name

          " #{name}: #{attribute.inspector.inspect_object(self.send(name))}"
        end
      end.compact.join(",")

      sprintf("#<%p:%0#18x%s>", self.class, self.object_id << 1, attributes)
    end
  end
end
