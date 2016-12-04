# frozen_string_literal: true

require "set"

require "spec_helper"

require "ceres/environment"

RSpec.describe Ceres::Object do
  using Ceres::Object

  it "calculates descendants" do
    a = Class.new
    b = Class.new(a)
    c = Class.new(b)
    d = Class.new(b)

    expect(a.descendants.to_set).to eq([b, c, d].to_set)
    expect(b.descendants.to_set).to eq([c, d].to_set)
    expect(c.descendants.to_set).to eq([].to_set)
    expect(d.descendants.to_set).to eq([].to_set)
  end
end
