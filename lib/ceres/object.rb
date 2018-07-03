require "ceres/attribute"

module Ceres
  class Object
    include Ceres::AttributeModule

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
