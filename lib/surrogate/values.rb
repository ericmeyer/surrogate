class Surrogate

  # Superclass for all types of values. Where a value is anything stored
  # in an instance variable on a surrogate, intended to be returned by an api method
  class Value
    # convert raw arguments into a value
    def self.factory(*args, &block)
      arg = args.first
      if block
        BlockValue.new &block
      elsif args.size > 1
        ValueQueue.new args
      elsif arg.kind_of? Exception
        Raisable.new arg
      elsif arg.kind_of? BaseValue
        arg
      else
        BaseValue.new arg
      end
    end

    # === the current set of possible values ===

    class BaseValue
      def initialize(value)
        @value = value
      end

      def value(method_name)
        @value
      end

      def factory(*args, &block)
        Value.factory(*args, &block)
      end
    end


    class BlockValue < BaseValue
      def initialize(&block)
        @block = block
      end

      def value(method_name)
        @block.call
      end
    end

    class Raisable < BaseValue
      def value(*)
        raise @value
      end
    end


    class ValueQueue < BaseValue
      QueueEmpty = Class.new SurrogateError

      def value(method_name)
        if empty?
          raise QueueEmpty
        else
          factory(dequeue).value(method_name)
        end
      end

      def queue
        @value
      end

      def dequeue
        raise QueueEmpty if empty?
        queue.shift
      end

      def empty?
        queue.empty?
      end
    end
  end
end
