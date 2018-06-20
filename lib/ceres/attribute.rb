require "ceres/reader"
require "ceres/writer"
require "ceres/inspector"

module Ceres
  class Attribute
    attr_reader :name

    attr_accessor :description
    attr_accessor :variable
    attr_accessor :target
    attr_accessor :reader
    attr_accessor :writer
    attr_accessor :inspector

    class DSL
      def initialize(object, &block)
        @object = object

        self.instance_exec(&block) if block
      end

      def description(text)
        @object.description = text
      end

      def target(symbol)
        @object.target = symbol
      end

      def variable(symbol)
        @object.variable = symbol
      end

      def reader(disabled: false, **args, &block)
        reader = Ceres::Reader.new(@object, **args, &block) unless disabled

        @object.reader = reader
      end

      def writer(disabled: false, &block)
        writer = Ceres::Writer.new(@object, &block) unless disabled

        @object.writer = writer
      end

      def inspector(disabled: false, &block)
        inspector = Ceres::Inspector.new(&block) unless disabled

        @object.inspector = inspector
      end
    end

    def initialize(name, &block)
      @name = name.to_sym

      @description = nil
      @variable = "@#{name}".to_sym

      @reader = Ceres::Reader.new(self)
      @writer = nil
      @inspector = Ceres::Inspector.new

      Ceres::Attribute::DSL.new(self, &block)
    end

    def apply(klass)
      @reader.apply(klass) if @reader
      @writer.apply(klass) if @writer

      klass
    end
  end
end
