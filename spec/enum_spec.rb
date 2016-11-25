# frozen_string_literal: true

require "spec_helper"

require "ceres/enum"

module EnumSpec
  class A < Ceres::Enum
    attribute :n, type: Integer

    order :n

    value :a, n: 0
    value :b, n: 1
    value :c, n: 2
  end
end

RSpec.describe Ceres::Enum do
  it "initializes values" do
    expect(EnumSpec::A.a.n).to eq(0)
    expect(EnumSpec::A.b.n).to eq(1)
    expect(EnumSpec::A.c.n).to eq(2)
  end

  it "allows Structure methods" do
    expect(EnumSpec::A.a <=> EnumSpec::A.b).to eq(-1)
  end

  it "lists all values" do
    expect(EnumSpec::A.values).to eq([EnumSpec::A.a, EnumSpec::A.b, EnumSpec::A.c])
  end

  it "converts to a hash" do
    expect(EnumSpec::A.to_h).to eq(a: EnumSpec::A.a, b: EnumSpec::A.b, c: EnumSpec::A.c)
  end

  it "adds checker methods" do
    expect(EnumSpec::A.a.a?).to eq(true)
    expect(EnumSpec::A.b.a?).to eq(false)
  end

  it "supports Enumerable methods" do
    expect(EnumSpec::A.max).to eq(EnumSpec::A.c)
  end
end
