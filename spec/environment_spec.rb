# frozen_string_literal: true

require "spec_helper"

require "ceres/environment"

RSpec.describe Ceres::Environment do
  it "defaults to development" do
    expect(Ceres.environment(environment: {})).to eq("development")
  end

  it "reads CERES_ENV" do
    prd = Ceres.environment(environment: { "CERES_ENV" => "production" })

    expect(prd).to eq("production")
  end

  it "reads RACK_ENV" do
    prd = Ceres.environment(environment: { "RACK_ENV" => "production" })

    expect(prd).to eq("production")
  end

  it "reads RAILS_ENV" do
    prd = Ceres.environment(environment: { "RAILS_ENV" => "production" })

    expect(prd).to eq("production")
  end

  it "prefers CERES_ENV" do
    env = { "RAILS_ENV" => "a", "RACK_ENV" => "b", "CERES_ENV" => "production" }
    prd = Ceres.environment(environment: env)

    expect(prd).to eq("production")
  end

  it "allows questionmark checks like rails" do
    expect(Ceres.environment(environment: {}).development?).to eq(true)
    expect(Ceres.environment(environment: {}).production?).to eq(false)
    expect(Ceres.environment(environment: { "CERES_ENV" => "production" }).production?).to eq(true)
  end

  it "compares to symbols" do
    prd = Ceres.environment(environment: { "CERES_ENV" => "production" })

    expect(prd).to eq(:production)
  end
end
