# frozen_string_literal: true

require "ceres/module"

module Ceres
  module Verify
    extend Ceres::Module

    def self.verify(value, type: nil, types: nil, enum: nil, element_type: nil)
      raise ArgumentError, "cannot specify both type and types)" if type && types

      if type && !value.is_a?(type)
        raise ArgumentError, "#{value.inspect} is not of type #{type.name}"
      end

      if types && !types.any? { |t| value.is_a?(t) }
        raise ArgumentError, "#{value.inspect} is not of types #{types.map(&:name).join(', ')}"
      end

      if enum && !enum.include?(value)
        raise ArgumentError, "#{value.inspect} is not one of #{enum.map(&:inspect).join(', ')}"
      end

      if element_type && !value.all? { |x| x.is_a?(element_type) }
        raise ArgumentError, "#{value.inspect} has elements of other type than #{element_type}"
      end
    end

    class_methods do
      def verify(value, **args)
        Ceres::Verify.verify(value, **args)
      end
    end

    def verify(value, **args)
      Ceres::Verify.verify(value, **args)
    end
  end
end
