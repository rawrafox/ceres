# frozen_string_literal: true

require "ceres/structure"

module Ceres
  class Environment < Ceres::Structure
    attribute :name

    equality :name, eq: false

    def self.current(environment: ENV)
      return new(name: environment["CERES_ENV"]) if environment.key?("CERES_ENV")

      if defined?(Rails)
        new(name: Rails.env.to_s)
      else
        return new(name: environment["RACK_ENV"]) if environment.key?("RACK_ENV")
        return new(name: environment["RAILS_ENV"]) if environment.key?("RAILS_ENV")

        new(name: "development")
      end
    end

    def respond_to_missing?(method, _ = false)
      method[-1] == "?"
    end

    def method_missing(method, *arguments)
      if method[-1] == "?"
        self.name == method[0 .. -2]
      else
        super
      end
    end

    def ==(other)
      case other
      when Ceres::Environment
        self.name == other.name
      when String
        self.name == other
      else
        false
      end
    end

    def to_s
      self.name
    end
  end

  def self.environment(environment: ENV)
    Ceres::Environment.current(environment: environment)
  end
end
