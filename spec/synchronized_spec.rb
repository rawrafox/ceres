# frozen_string_literal: true

require "spec_helper"

require "ceres/synchronized"

module SynchronizedSpec
  class A
    include Ceres::Synchronized

    def initialize(q1, q2)
      @q1 = q1
      @q2 = q2
    end

    synchronized def a
      @q1.push(:a)
      @q2.pop
    end

    def b
      @q1.push(:b)
      @q2.pop
    end

    synchronized def c
      a
    end
  end
end

RSpec.describe Ceres::Module do
  before do
    @in = Queue.new
    @out = Queue.new

    @o = SynchronizedSpec::A.new(@out, @in)
  end

  it "takes the lock in a synchronized method" do
    expect(@o.mutex.locked?).to_not be(true)
    t = Thread.new { @o.a }
    expect(@out.pop).to be(:a)
    expect(@o.mutex.locked?).to be(true)
    @in.push(:a)
    expect(t.value).to be(:a)
    expect(@o.mutex.locked?).to_not be(true)
  end

  it "does not take the lock in an unsynchronized method" do
    expect(@o.mutex.locked?).to_not be(true)
    t = Thread.new { @o.b }
    expect(@out.pop).to be(:b)
    expect(@o.mutex.locked?).to_not be(true)
    @in.push(:b)
    expect(t.value).to be(:b)
    expect(@o.mutex.locked?).to_not be(true)
  end

  it "allows recursive locking" do
    expect(@o.mutex.locked?).to_not be(true)
    t = Thread.new { @o.c }
    expect(@out.pop).to be(:a)
    expect(@o.mutex.locked?).to be(true)
    @in.push(:a)
    expect(t.value).to be(:a)
    expect(@o.mutex.locked?).to_not be(true)
  end
end
