module Rope
  # Specifies an interior node.  To gets its data, its children are recursively
  # combined.
  class ConcatenationNode
    # Left and right nodes
    attr_reader :left, :right

    # Length of the data associated with this node as its root
    attr_reader :length

    # Depth of the tree with this node as its root
    attr_reader :depth

    # Initializes a new concatenation node.
    def initialize(left, right)
      @left = left
      @right = right

      @length = left.length + right.length
      @depth = [left.depth, right.depth].max + 1
    end

    # Concatenates this node with another (non-destructive)
    def +(other)
      ConcatenationNode.new(self, other)
    end

    # Gets the string data for the node
    def to_s
      # TODO: Can this be memoized somehow?
      left.to_s + right.to_s
    end

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

    # Rebalance the tree with this node as its root
    def rebalance!
      # TODO
    end

    # Returns a concatenation node that represents a slice of this rope.
    # Attempts to reuse nodes in this rope if possible.
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
        ConcatenationNode.new(@left.subtree(from, llen), @right.subtree(0, rlen))
      else
        # Requested subtree is entirely in the left subtree
        @left.subtree(from, length)
      end
    end
  end
end

