# frozen_string_literal: true

require "ceres/refinements/array"

module Ceres
  module Object
    def self.descendants(klass, only_direct: false)
      descendants = ObjectSpace.each_object(klass.singleton_class).reject { |k| k == klass }

      if only_direct
        descendants.reject { |k| descendants.any? { |c| k < c } }
      else
        descendants
      end
    end

    refine ::Object do
      def descendants(only_direct: false)
        Ceres::Object.descendants(self, only_direct: only_direct)
      end
    end
  end
end
