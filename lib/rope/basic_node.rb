module Rope
	class BasicNode
    # Length of the underlying data in the tree and its descendants
    attr_reader :length

    # Depth of the tree
    attr_reader :depth

    # The underlying data in the tree
    attr_reader :data

    # Concatenates this tree with another tree (non-destructive to either
    # tree)
    def +(other)
      InteriorNode.new(self, other)
    end

    # Gets the string representation of the underlying data in the tree
    def to_primitive
      data
    end

    # Returns the Node that contains this index or nil if the index is out of bounds
    def segment(index)
    	raise NotImplementedError
    end

    # Rebalances this tree
    def rebalance!
    	raise NotImplementedError
    end

    #Swaps out the data in this node to be rhs. Must be same length
    def replace!(index, length, rhs)
    	raise NotImplementedError
    end

	end
end