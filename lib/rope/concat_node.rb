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

    # Rebalance the tree with this node as its root
    def rebalance!
      # TODO
    end
  end
end

