# frozen_string_literal: true

module Ceres
  module Object
    def self.descendants_of(klass)
      ObjectSpace.each_object(klass.singleton_class).select { |k| k != klass }
    end

    refine ::Object do
      def descendants
        Ceres::Object.descendants_of(self)
      end
    end
  end
end
