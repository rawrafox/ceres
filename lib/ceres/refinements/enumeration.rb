# frozen_string_literal: true

require "ceres/verify"

module Ceres
  module Enumeration
    include Ceres::Verify

    SUPPORTED_CLASSES = [::Array, ::Enumerator, ::Hash].freeze

    def self.only(this, *args)
      verify this, types: SUPPORTED_CLASSES

      this.select { |element| args.include?(element) }
    end

    def self.without(this, *args)
      verify this, types: SUPPORTED_CLASSES

      this.reject { |element| args.include?(element) }
    end

    module Refinement
      def only(*args)
        Ceres::Enumerator.only(self, *args)
      end

      def without(*args)
        Ceres::Enumerator.without(self, *args)
      end
    end

    SUPPORTED_CLASSES.each do |klass|
      refine klass do
        include Refinement
      end
    end
  end
end
