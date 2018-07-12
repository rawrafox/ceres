# frozen_string_literal: true

require "spec_helper"

require "ceres/children"

RSpec.describe Ceres::Children do
  before do
    @class = Class.new { include Ceres::Children }
    @child = Struct.new(:name)
  end

  context "adding and removing children" do
    it "adds child okay" do
      o = @class.new
      a = @child.new(:a)

      expect(o.add_child(a)).to eq(a)
      expect(o.children).to eq([a])
    end

    it "can add multiple children" do
      o = @class.new
      a = o.add_child(@child.new(:a))
      b = o.add_child(@child.new(:b))

      expect(o.children).to eq([a, b])
    end

    it "fails when adding the same key twice" do
      o = @class.new
      a = o.add_child(@child.new(:a))
      b = @child.new(:a)

      expect { o.add_child(b) }.to raise_error(ArgumentError)
    end

    it "allows adding the same key twice if replace is set" do
      o = @class.new
      a = o.add_child(@child.new(:a))
      b = o.add_child(@child.new(:a), replace: true)

      expect(o.children).to eq([b])
    end

    it "removes children okay" do
      o = @class.new
      a = o.add_child(@child.new(:a))

      expect(o.remove_child(:a)).to eq(a)
      expect(o.children).to eq([])
    end

    it "cannot remove non-existing child" do
      o = @class.new

      expect { o.remove_child(:a) }.to raise_error(KeyError)
    end

    it "calls block when removing non-existant child" do
      o = @class.new
      key = nil

      o.remove_child(:a) { |k| key = k }

      expect(key).to eq(:a)
    end
  end

  context "enumeration" do
    it "can iterate over children" do
      o = @class.new
      a = o.add_child(@child.new(:a))
      b = o.add_child(@child.new(:b))
      c = o.add_child(@child.new(:c))

      children = []

      expect(o.each_child { |c| children << c }).to eq(o)
      expect(children).to eq([a, b, c])
    end

    it "can select children" do
      o = @class.new
      a = o.add_child(@child.new(:a))
      b = o.add_child(@child.new(:b))
      c = o.add_child(@child.new(:c))

      expect(o.select_children { |c| c.name == :b }).to eq([b])
    end
  end

  context "dereferencing" do
    it "can dereference" do
      o = @class.new
      a = o.add_child(@child.new(:a))

      expect(o[:a]).to eq(a)
    end

    it "can fetch" do
      o = @class.new
      a = o.add_child(@child.new(:a))

      expect(o.fetch(:a)).to eq(a)
    end

    it "can fetch default value" do
      o = @class.new

      expect(o.fetch(:a, 0)).to eq(0)
    end

    it "can fetch block" do
      o = @class.new

      expect(o.fetch(:a) { |k| k }).to eq(:a)
    end

    it "fails to fetch without a fallback" do
      o = @class.new

      expect { o.fetch(:a) }.to raise_error(KeyError)
    end

    it "can fetch one value" do
      o = @class.new
      a = o.add_child(@child.new(:a))

      expect(o.fetch_values(:a)).to eq([a])
    end

    it "can fetch multiple values" do
      o = @class.new
      a = o.add_child(@child.new(:a))

      expect(o.fetch_values(:a, :a)).to eq([a, a])
    end

    it "fetch_values falls back to calling block" do
      o = @class.new
      a = o.add_child(@child.new(:a))

      expect(o.fetch_values(:a, :b) { |k| k }).to eq([a, :b])
    end

    it "fetch_values errors when no child" do
      o = @class.new
      a = o.add_child(@child.new(:a))

      expect { o.fetch_values(:a, :b) }.to raise_error(KeyError)
    end

    it "can dig" do
      o = @class.new
      a = o.add_child(@child.new(:a))

      expect(o.dig(:a, :name)).to eq(:a)
    end

    it "can dig just one level" do
      o = @class.new
      a = o.add_child(@child.new(:a))

      expect(o.dig(:a)).to eq(a)
    end

    it "dig fails into nil" do
      o = @class.new

      expect(o.dig(:a)).to eq(nil)
    end
  end
end
