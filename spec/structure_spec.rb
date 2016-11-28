# frozen_string_literal: true

require "spec_helper"

require "ceres/structure"

module StructureSpec
  class A < Ceres::Structure
    attribute :a, type: String

    order :a
  end

  class B < Ceres::Structure
    attribute :a, type: String
    attribute :b, type: Integer, default: 1

    equality :a
    order :b
  end

  class C < B
    attribute :a, default: "c"
  end

  class D < Ceres::Structure
    attribute :a, enum: %i(a b c)
  end

  class E < Ceres::Structure
    attribute :a, optional: true
  end

  class F < Ceres::Structure
    array :a, element_type: String
  end
  
  class G < Ceres::Structure
    private attribute :g, type: String
  end
end

RSpec.describe Ceres::Structure do
  context "attributes" do
    it "initializes attributes" do
      expect(StructureSpec::A.new(a: "a").a).to eq("a")
    end

    it "initializes array attributes" do
      expect(StructureSpec::F.new(a: ["a"]).a).to eq(["a"])
    end

    it "initializes multiple attributes" do
      v = StructureSpec::B.new(a: "a", b: 1)

      expect(v.a).to eq("a")
      expect(v.b).to eq(1)
    end

    it "raises InvalidArgument if array attribute is not array" do
      expect { StructureSpec::F.new(a: 1) }.to raise_error(ArgumentError)
    end

    it "raises InvalidArgument if extra attribute is provided" do
      expect { StructureSpec::A.new(a: 1, b: 2) }.to raise_error(ArgumentError)
    end
  end

  context "definitions" do
    it "does not allow overwriting attributes in same class" do
      expect do
        Class.new(Ceres::Structure) do
          attribute :a
          attribute :a
        end
      end.to raise_error(ArgumentError)
    end
  end

  context "default" do
    it "fills in attribute with default" do
      v = StructureSpec::B.new(a: "a")

      expect(v.a).to eq("a")
      expect(v.b).to eq(1)
    end

    it "raises InvalidArgument if there is no default" do
      expect { StructureSpec::A.new }.to raise_error(ArgumentError)
    end
  end

  context "element_type" do
    it "initializes attribute if elements are of correct type" do
      expect(StructureSpec::F.new(a: ["a"]).a).to eq(["a"])
    end

    it "raises InvalidArgument if value is not in enum" do
      expect { StructureSpec::F.new(a: [:a]) }.to raise_error(ArgumentError)
    end
  end

  context "enum" do
    it "initializes attribute if value is in enum" do
      expect(StructureSpec::D.new(a: :a).a).to eq(:a)
    end

    it "raises InvalidArgument if value is not in enum" do
      expect { StructureSpec::D.new(a: :d) }.to raise_error(ArgumentError)
    end
  end

  context "equality" do
    it "compares equal if the same class" do
      a = StructureSpec::B.new(a: "a")
      b = StructureSpec::B.new(a: "a")

      expect(a).to eq(b)
      expect(a.hash).to eq(b.hash)
    end

    it "does not compare equal if different classes" do
      a = StructureSpec::B.new(a: "a")
      b = StructureSpec::C.new(a: "a")

      expect(a).not_to eq(b)
      expect(a.hash).not_to eq(b.hash)
    end

    it "compares only the attributes defined" do
      a = StructureSpec::C.new(a: "a")
      b = StructureSpec::C.new(a: "a", b: 4)

      expect(a).to eq(b)
      expect(a.hash).to eq(b.hash)
    end
  end

  context "inheritance" do
    it "inherits attributes" do
      v = StructureSpec::C.new(a: "a", b: 1)

      expect(v.a).to eq("a")
      expect(v.b).to eq(1)
    end

    it "overrides options" do
      v = StructureSpec::C.new(b: 1)

      expect(v.a).to eq("c")
      expect(v.b).to eq(1)
    end
  end

  context "optional" do
    it "allows nil if optional" do
      expect(StructureSpec::E.new(a: nil).a).to eq(nil)
    end

    it "allows default to be nil if optional" do
      expect(StructureSpec::E.new.a).to eq(nil)
    end

    it "raises InvalidArgument if attribute is not optional" do
      expect { StructureSpec::A.new(a: nil) }.to raise_error(ArgumentError)
    end
  end

  context "order" do
    it "sorts according to order" do
      a = StructureSpec::B.new(a: "a", b: 1)
      b = StructureSpec::B.new(a: "b", b: 2)

      expect(a > b).to be(false)
      expect(a < b).to be(true)
      expect(a <=> b).to be(-1)
      expect(b <=> a).to be(1)
    end

    it "implements `==` when ordered" do
      a = StructureSpec::A.new(a: "a")
      b = StructureSpec::A.new(a: "b")

      expect(a == a).to be(true) # rubocop:disable Lint/UselessComparison
      expect(a != b).to be(true)
    end
  end

  context "private" do
    it "supports private attributes" do
      expect { StructureSpec::G.new(g: "g").g }.to raise_error(NoMethodError)
    end
  end

  context "type" do
    it "initializes attribute if value has correct type" do
      expect(StructureSpec::A.new(a: "a").a).to eq("a")
    end

    it "raises InvalidArgument if type is wrong" do
      expect { StructureSpec::A.new(a: 1) }.to raise_error(ArgumentError)
    end
  end
end
