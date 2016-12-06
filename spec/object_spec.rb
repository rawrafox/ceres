# frozen_string_literal: true

require "set"

require "spec_helper"

require "ceres/environment"

RSpec.describe Ceres::Object do
  before do
    @a = Class.new
    @b = Class.new(@a)
    @c = Class.new(@b)
    @d = Class.new(@b)
  end

  it "calculates descendants_of" do
    expect(Ceres::Object.descendants_of(@a).to_set).to eq([@b, @c, @d].to_set)
    expect(Ceres::Object.descendants_of(@b).to_set).to eq([@c, @d].to_set)
    expect(Ceres::Object.descendants_of(@c).to_set).to eq([].to_set)
    expect(Ceres::Object.descendants_of(@d).to_set).to eq([].to_set)
  end

  it "calculates direct_descendants_of" do
    expect(Ceres::Object.direct_descendants_of(@a).to_set).to eq([@b].to_set)
    expect(Ceres::Object.direct_descendants_of(@b).to_set).to eq([@c, @d].to_set)
    expect(Ceres::Object.direct_descendants_of(@c).to_set).to eq([].to_set)
    expect(Ceres::Object.direct_descendants_of(@d).to_set).to eq([].to_set)
  end

  using Ceres::Object

  it "calculates descendants", refinements: true do
    expect(@a.descendants.to_set).to eq([@b, @c, @d].to_set)
    expect(@b.descendants.to_set).to eq([@c, @d].to_set)
    expect(@c.descendants.to_set).to eq([].to_set)
    expect(@d.descendants.to_set).to eq([].to_set)
  end

  it "calculates direct_descendants", refinements: true do
    expect(@a.direct_descendants.to_set).to eq([@b].to_set)
    expect(@b.direct_descendants.to_set).to eq([@c, @d].to_set)
    expect(@c.direct_descendants.to_set).to eq([].to_set)
    expect(@d.direct_descendants.to_set).to eq([].to_set)
  end
end
