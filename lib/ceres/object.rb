# frozen_string_literal: true

module Ceres
  module Object
    def self.descendants_of(klass)
      ObjectSpace.each_object(klass.singleton_class).select { |k| k != klass }
    end

    def self.direct_descendants_of(klass)
      descendants = self.descendants_of(klass)

      descendants.reject { |k| descendants.any? { |c| c > k } }
    end

    refine ::Object do
      def descendants
        Ceres::Object.descendants_of(self)
      end

      def direct_descendants
        Ceres::Object.direct_descendants_of(self)
      end
    end
  end
end
