# frozen_string_literal: true

require "spec_helper"

require "ceres/module"

module ModuleSpec
  module A
    extend Ceres::Module

    class_methods do
      def a
        :a
      end
    end

    class_methods do
      def after_include_worked!
        @after_include = true
      end

      def after_include_worked?
        @after_include
      end
    end

    after_include do
      after_include_worked!
    end

    after_initialize do
      after_initialize_worked!
    end

    def a
      :a
    end

    def after_initialize_worked!
      @after_initialize = true
    end

    def after_initialize_worked?
      @after_initialize
    end
  end

  module B
    extend Ceres::Module

    include A

    module ClassMethods
      def a
        [super, :b]
      end
    end

    def a
      [super, :b]
    end

    def b
      :b
    end

    after_initialize do
      after_initialize2_worked!
    end

    def after_initialize2_worked!
      @after_initialize2 = true
    end

    def after_initialize2_worked?
      @after_initialize2
    end
  end

  module C
    extend Ceres::Module

    include A, B
  end

  module D
    extend Ceres::Module

    class_methods do
      def d
        [:d, super]
      end
    end

    def d
      [:d, super]
    end
  end

  # module E
  #   extend Ceres::Module
  #
  #   prepend D
  #
  #   class_methods do
  #     def d
  #       :e
  #     end
  #   end
  #
  #   def d
  #     :e
  #   end
  # end
end

RSpec.describe Ceres::Module do
  before do
    @klass = Class.new
  end

  it "includes normally" do
    @klass.include(ModuleSpec::A)

    expect(@klass.new.a).to eq(:a)
  end

  it "extends class methods" do
    @klass.include(ModuleSpec::A)

    expect(@klass.a).to eq(:a)
    expect((class << @klass; included_modules; end)[0]).to eq(ModuleSpec::A::ClassMethods)
  end

  it "runs after_include" do
    @klass.include(ModuleSpec::A)

    expect(@klass.after_include_worked?).to eq(true)
  end

  it "runs after_initialize" do
    @klass.include(ModuleSpec::A)

    expect(@klass.new.after_initialize_worked?).to eq(true)
  end

  it "includes dependencies" do
    @klass.include(ModuleSpec::B)

    expect(@klass.a).to eq(%i(a b))

    expect(@klass.new.a).to eq(%i(a b))
    expect(@klass.new.b).to eq(:b)

    expect(@klass.included_modules[0..1]).to eq([ModuleSpec::B, ModuleSpec::A])
  end

  it "runs after_initialize in dependencies" do
    @klass.include(ModuleSpec::B)

    expect(@klass.new.after_initialize_worked?).to eq(true)
    expect(@klass.new.after_initialize2_worked?).to eq(true)
  end

  it "includes multiple dependencies" do
    @klass.include(ModuleSpec::C)

    expect(@klass.included_modules[0..2]).to eq([ModuleSpec::C, ModuleSpec::B, ModuleSpec::A])
  end

  # it "prepends on classes" do
  #   @klass.prepend(ModuleSpec::D)
  #
  #   @klass.class_eval do
  #     def d
  #       :e
  #     end
  #   end
  #
  #   expect(@klass.new.d).to eq(%i(d e))
  # end

  # it "prepends on modules" do
  #   @klass.include(ModuleSpec::E)
  #
  #   expect(@klass.new.d).to eq(%i(d e))
  #   expect(ModuleSpec::E.d).to eq(%i(d e))
  # end
end
