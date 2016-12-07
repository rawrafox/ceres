# frozen_string_literal: true

require "ceres/module"

module Ceres
  module Verify
    extend Ceres::Module

    PARAMS = %i(element_type enum minimum_count type types).freeze

    def self.verify(value, element_type: nil, enum: nil, minimum_count: nil, type: nil, types: nil)
      raise ArgumentError, "cannot specify both type and types)" if type && types

      verify_element_type(value, element_type)
      verify_enum(value, enum)
      verify_minimum_count(value, minimum_count)
      verify_type(value, type)
      verify_types(value, types)
    end
  end

  # Ceres internals
  module Verify
    private_class_method def self.verify_element_type(value, element_type)
      return unless element_type

      unless value.is_a?(Enumerable)
        raise ArgumentError, "#{value.inspect} is not an enumerable object"
      end

      unless value.all? { |x| x.is_a?(element_type) }
        raise ArgumentError, "#{value.inspect} has elements of other type than #{element_type}"
      end
    end

    private_class_method def self.verify_enum(value, enum)
      return unless enum

      unless enum.include?(value)
        raise ArgumentError, "#{value.inspect} is not one of #{enum.map(&:inspect).join(', ')}"
      end
    end

    private_class_method def self.verify_minimum_count(value, minimum_count)
      return unless minimum_count

      unless value.count >= minimum_count
        raise ArgumentError, "#{value.inspect} has fewer elements than #{minimum_count}"
      end
    end

    private_class_method def self.verify_type(value, type)
      return unless type

      unless value.is_a?(type)
        raise ArgumentError, "#{value.inspect} is not of type #{type.name}"
      end
    end

    private_class_method def self.verify_types(value, types)
      return unless types

      unless types.any? { |t| value.is_a?(t) }
        raise ArgumentError, "#{value.inspect} is not of types #{types.map(&:name).join(', ')}"
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

  def self.verify(value, **args)
    Ceres::Verify.verify(value, **args)
  end
end
