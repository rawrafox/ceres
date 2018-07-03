# frozen_string_literal: true

require "spec_helper"

require "ceres/attribute"

RSpec.describe Ceres::Attribute do
  context "name" do
    it "can be read" do
      expect(Ceres::Attribute.new(:name).name).to eq(:name)
    end

    it "is interned" do
      expect(Ceres::Attribute.new("name").name).to eq(:name)
    end
  end

  context "description" do
    it "defaults to nil" do
      expect(Ceres::Attribute.new(:name).description).to be_nil
    end

    it "can be read" do
      a = Ceres::Attribute.new(:name) do
        description "A description"
      end

      expect(a.description).to eq("A description")
    end
  end

  context "reader" do
    it "has a default" do
      a = Ceres::Attribute.new(:name)

      expect(a.reader).to_not be_nil
    end

    it "can be replaced" do
      a = Ceres::Attribute.new(:name) { reader }

      expect(a.reader).to_not be_nil
    end

    it "can be disabled" do
      a = Ceres::Attribute.new(:name) { reader disabled: true }

      expect(a.reader).to be_nil
    end

    it "can have another backing variable" do
      c = Ceres::Attribute.new(:name) { variable :@abc }.apply(Class.new)
      o = c.new
      o.instance_variable_set(:@abc, "abc")

      expect(o.name).to eq("abc")
    end

    it "can have another target" do
      c1 = Ceres::Attribute.new(:name) { target :@abc }.apply(Class.new)
      c2 = Ceres::Attribute.new(:name).apply(Class.new)

      o1 = c1.new
      o2 = c2.new

      o1.instance_variable_set(:@abc, o2)
      o2.instance_variable_set(:@name, "abc")

      expect(o1.name).to eq("abc")
    end
  end
  
  context "writer" do
    it "has no default" do
      expect(Ceres::Attribute.new(:name).writer).to be_nil
    end

    it "can have a writer" do
      expect(Ceres::Attribute.new(:name) { writer }.writer).to_not be_nil
    end

    it "can be explicitly disabled" do
      expect(Ceres::Attribute.new(:name) { writer disabled: true }.writer).to be_nil
    end

    it "can have another backing variable" do
      c = Ceres::Attribute.new(:name) { writer; variable :@abc }.apply(Class.new)
      o = c.new
      o.name = "abc"

      expect(o.instance_variable_get(:@abc)).to eq("abc")
    end

    it "can have another target" do
      c1 = Ceres::Attribute.new(:name) { writer; target :@abc }.apply(Class.new)
      c2 = Ceres::Attribute.new(:name).apply(Class.new)

      o1 = c1.new
      o2 = c2.new

      o1.instance_variable_set(:@abc, o2)
      o1.name = "abc"

      expect(o2.name).to eq("abc")
    end
  end

  context "apply" do
    it "adds a reader" do
      c = Ceres::Attribute.new(:name).apply(Class.new)

      expect { c.new.name }.to_not raise_error
    end

    it "adds a writer" do
      c = Ceres::Attribute.new(:name) { writer }.apply(Class.new)

      expect { c.new.name = "name" }.to_not raise_error
    end
  end
end
