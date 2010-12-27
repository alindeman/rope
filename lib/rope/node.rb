module Rope
  class Node
    # Length of the underlying data in the tree and its descendants
    attr_reader :length

    # Depth of the tree
    attr_reader :depth

    # The underlying data in the tree
    attr_reader :data

    # Concatenates this tree with another tree (non-destructive to either
    # tree)
    def +(other)
      ConcatenationNode.new(self, other)
    end

    # Gets the string representation of the underlying data in the tree
    def to_s
      data.to_s
    end

    # Rebalances this tree
    def rebalance!
    end
  end
end
