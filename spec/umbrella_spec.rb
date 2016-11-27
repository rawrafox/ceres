# frozen_string_literal: true

require "spec_helper"

require "ceres"

RSpec.describe Ceres do
  it "has a version" do
    expect(Ceres::VERSION.class).to be(String)
  end
end
