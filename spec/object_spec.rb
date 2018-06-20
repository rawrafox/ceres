# frozen_string_literal: true

require "spec_helper"

require "ceres/object"

RSpec.describe Ceres::Object do
  context "attribute" do
    it "can add an attribute" do
      c = Class.new(Ceres::Object) do
        attribute :name do
          variable :@xyz
          reader { @xyz + "!" }
          writer { |v| v.gsub(/!/, "") }
        end
      end

      o = c.new
      o.name = "Aria!!!!!"
      expect(o.instance_variable_get(:@xyz)).to eq("Aria")
      expect(o.name).to eq("Aria!")
    end

    it "can list attributes" do
      c = Class.new(Ceres::Object) do
        attribute :a
        attribute :b
      end

      expect(c.attributes.map(&:name)).to eq([:a, :b])
    end

    it "can list inherited attributes" do
      c1 = Class.new(Ceres::Object) do
        attribute :b
      end

      c2 = Class.new(c1) do
        attribute :a
      end

      expect(c2.attributes.map(&:name)).to eq([:a, :b])
    end
  end

  context "inspect" do
    it "works on empty object" do
      c = Class.new(Ceres::Object)
      o = c.new

      expect(o.inspect).to eq(sprintf("#<%p:%0#18x>", c, o.object_id << 1))
    end

    it "works on an object with attributes" do
      c = Class.new(Ceres::Object) do
        attribute :name
      end

      o = c.new

      expect(o.inspect).to eq(sprintf("#<%p:%0#18x name: nil>", c, o.object_id << 1))
    end
  end
end
