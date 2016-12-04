# frozen_string_literal: true

module Ceres
  module Object
    refine ::Object do
      def descendants
        ObjectSpace.each_object(singleton_class).select { |k| k != self }
      end
    end
  end
end
