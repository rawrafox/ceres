# frozen_string_literal: true

require "spec_helper"

require "ceres/reader"

RSpec.describe Ceres::Reader do
  before do
    @attribute = OpenStruct.new(name: :name, variable: :@name)
  end
  
  context "to_proc" do
    it "can cache values" do
      r = Ceres::Reader.new(@attribute, cache: true) { rand }.to_proc
      o = Object.new

      expect(o.instance_exec(&r)).to eq(o.instance_exec(&r))
    end

    it "doesn't cache if caching is not enabled" do
      r = Ceres::Reader.new(@attribute) { rand }.to_proc
      o = Object.new

      expect(o.instance_exec(&r)).to_not eq(o.instance_exec(&r))
    end
  end

  context "apply" do
    it "adds a reader" do
      r = Ceres::Reader.new(@attribute) { rand }
      c = Class.new

      r.apply(c)

      expect { c.new.name }.to_not raise_error
    end

    it "has a working default reader" do
      r = Ceres::Reader.new(@attribute)
      c = Class.new
      o = c.new
      o.instance_variable_set(:@name, "name")

      r.apply(c)

      expect(o.name).to eq("name")
    end
  end
end
