# frozen_string_literal: true

require "spec_helper"

require "ceres/writer"

RSpec.describe Ceres::Writer do
  before do
    @attribute = OpenStruct.new(name: :name, variable: :@name)
  end

  context "to_proc" do
    it "writes to an instance variable by default" do
      r = Ceres::Writer.new(@attribute).to_proc
      o = Object.new
      
      expect(o.instance_exec("name", &r)).to eq("name")
      expect(o.instance_variable_get(:@name)).to eq("name")
    end
  end

  context "apply" do
    it "adds a writer" do
      r = Ceres::Writer.new(@attribute) { |v| "Hello, #{v}!" }
      c = Class.new
      o = c.new

      r.apply(c)

      expect(o.name = "Aria").to eq("Aria")
      expect(o.instance_variable_get(:@name)).to eq("Hello, Aria!")
    end

    it "allows you to overwrite the variable it writes to" do
      r = Ceres::Writer.new(OpenStruct.new(name: :name, variable: :@xyz))
      c = Class.new
      o = c.new

      r.apply(c)

      expect(o.name = "name").to eq("name")
      expect(o.instance_variable_get(:@xyz)).to eq("name")
    end

    it "has a working default writer" do
      r = Ceres::Writer.new(@attribute)
      c = Class.new
      o = c.new

      r.apply(c)

      expect(o.name = "Aria").to eq("Aria")
      expect(o.instance_variable_get(:@name)).to eq("Aria")
    end
  end
end
