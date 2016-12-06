# frozen_string_literal: true

require "ceres/refinements/enumeration"
require "ceres/verify"

module Ceres
  module Object
    include Ceres::Verify

    def self.descendants(this, only_direct: false)
      verify this, type: ::Class

      descendants = ObjectSpace.each_object(this.singleton_class)
      descendants = Ceres::Enumeration.without(descendants, this)

      if only_direct
        descendants.reject { |k| descendants.any? { |c| k < c } }
      else
        descendants
      end
    end

    refine ::Object do
      def descendants(**args)
        Ceres::Object.descendants(self, **args)
      end
    end
  end
end
