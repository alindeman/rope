require 'rope/node'

module Rope
  # Specifies an interior node.  Its underlying data is retrieved by combining
  # its children recursively.
  class ConcatenationNode < Node
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
        # TODO: arg0.is_a?(Fixnum)
        # TODO: arg0.is_a?(Range)
        # TODO: arg0.is_a?(Regexp)
        # TODO: arg0.is_a?(String)
      else
        arg1 = args[0] # may be slightly confusing; refer to method definition
        if arg0.is_a?(Fixnum) && arg1.is_a?(Fixnum) # Fixnum, Fixnum
          subtree(arg0, arg1)
        end
      end
    end

    # Rebalances this tree
    def rebalance!
      # TODO
    end

    # Returns a node that represents a slice of this tree
    def subtree(from, length)
      # TODO: This likely can be refactored

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
  end
end

