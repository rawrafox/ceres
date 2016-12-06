# frozen_string_literal: true

require "set"

require "spec_helper"

require "ceres/refinements/object"

RSpec.describe Ceres::Object do
  before do
    @a = Class.new
    @b = Class.new(@a)
    @c = Class.new(@b)
    @d = Class.new(@b)
  end

  it "calculates descendants" do
    expect(Ceres::Object.descendants(@a).to_set).to eq([@b, @c, @d].to_set)
    expect(Ceres::Object.descendants(@b).to_set).to eq([@c, @d].to_set)
    expect(Ceres::Object.descendants(@c).to_set).to eq([].to_set)
    expect(Ceres::Object.descendants(@d).to_set).to eq([].to_set)
  end

  it "calculates direct descendants" do
    expect(Ceres::Object.descendants(@a, only_direct: true).to_set).to eq([@b].to_set)
    expect(Ceres::Object.descendants(@b, only_direct: true).to_set).to eq([@c, @d].to_set)
    expect(Ceres::Object.descendants(@c, only_direct: true).to_set).to eq([].to_set)
    expect(Ceres::Object.descendants(@d, only_direct: true).to_set).to eq([].to_set)
  end

  using Ceres::Object

  it "calculates descendants", refinements: true do
    expect(@a.descendants.to_set).to eq([@b, @c, @d].to_set)
    expect(@b.descendants.to_set).to eq([@c, @d].to_set)
    expect(@c.descendants.to_set).to eq([].to_set)
    expect(@d.descendants.to_set).to eq([].to_set)
  end

  it "calculates direct_descendants", refinements: true do
    expect(@a.descendants(only_direct: true).to_set).to eq([@b].to_set)
    expect(@b.descendants(only_direct: true).to_set).to eq([@c, @d].to_set)
    expect(@c.descendants(only_direct: true).to_set).to eq([].to_set)
    expect(@d.descendants(only_direct: true).to_set).to eq([].to_set)
  end
end
