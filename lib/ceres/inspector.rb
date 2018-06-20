module Ceres
  class Inspector
    def initialize(&block)
      @block = block
    end

    def inspect_object(object)
      if @block
        @block.call(object)
      else
        object
      end.inspect
    rescue => e
      "<EXCEPTION RAISED IN INSPECT: #{e.inspect}>"
    end
  end
end
