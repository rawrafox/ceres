# frozen_string_literal: true

require "ceres/module"

module Ceres
  module Synchronized
    extend Ceres::Module

    class_methods do
      def synchronized(*methods)
        methods.each do |method_name|
          old_method_name = "unsynchronized_#{method_name}".to_sym

          alias_method old_method_name, method_name

          define_method(method_name) do |*args, &block|
            synchronize { send(old_method_name, *args, &block) }
          end
        end
      end
    end

    on_initialize do
      @mutex = Mutex.new
    end

    on_include do
      attr_reader :mutex
    end

    def synchronize(&block)
      @mutex.synchronize(&block)
    end
  end
end
