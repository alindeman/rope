require 'rope/basic_node'

module Rope
  # Specifies an interior node.  Its underlying data is retrieved by combining
  # its children recursively.
	class InteriorNode < BasicNode
    # Left and right nodes
    attr_reader :left, :right

    # Initializes a new concatenation node.
    def initialize(left, right)
      @left = left
      @right = right

      @length = left.length + right.length
      @depth = [left.depth, right.depth].max + 1
    end

    # Gets the underlying data in the tree
    def data
      left.data + right.data
    end

    # Gets a slice of the underlying data in the tree
    def slice(arg0, *args)
      if args.length == 0
        if arg0.is_a?(Fixnum)
          slice(arg0, 1)
        elsif arg0.is_a?(Range)
          from, to = arg0.minmax

          # Special case when the range doesn't actually describe a valid range
          return nil if from.nil? || to.nil?

          # Normalize so both from and to are positive indices
          if from < 0
            from += @length
          end
          if to < 0
            to += @length
          end

          if from <= to
            subtree(from, (to - from) + 1)
          else
            # Range first is greater than range last
            # Return empty string to match what String does
            raise "TODO"
          end
        end

        # TODO: arg0.is_a?(Range)
        # TODO: arg0.is_a?(Regexp)
        # TODO: arg0.is_a?(String)
      else
        arg1 = args[0] # may be slightly confusing; refer to method definition
        if arg0.is_a?(Fixnum) && arg1.is_a?(Fixnum) # Fixnum, Fixnum
          if arg1 >= 0
            subtree(arg0, arg1)
          else
            # Negative length, return nil to match what String does
            nil
          end
        end

        # TODO: arg0.is_a?(Regexp) && arg1.is_a?(Fixnum)
      end
    end

    # Rebalances this tree
    def rebalance!
      # TODO
    end

    # Returns a node that represents a slice of this tree
    def subtree(from, length)
      # Translate to positive index if given a negative one
      if from < 0
        from += @length
      end

      # If more than @length characters are requested, truncate
      length = [(@length - from), length].min

      # Entire length requested
      return self if length == @length

      # Check if the requested subtree is entirely in the right subtree
      rfrom = from - @left.length
      return @right.subtree(rfrom, length) if rfrom >= 0

      llen = @left.length - from
      rlen = length - llen
      if rlen > 0
        # Requested subtree overlaps both the left and the right subtree
        @left.subtree(from, llen) + @right.subtree(0, rlen)
      else
        # Requested subtree is entirely in the left subtree
        @left.subtree(from, length)
      end
    end

    def segment(index)
      # Translate to positive index if given a negative one
      if index < 0
        index += @length
      end

      # Falls outside bounds
      return nil if index >= @length

      rindex = index - @left.length
      if rindex < 0
        # Requested index is in the left subtree
        @left.segment(index)
      else
        # Requested index is in the right subtree
        @right.segment(rindex)
      end
    end
  end
end
