require 'rope/basic_node'

module Rope
  # Specifies a leaf node that contains a basic string
	class LeafNode < BasicNode
    extend Forwardable

    # The underlying data in the tree
    attr_reader :data

    def_delegator :@data, :slice

    # Initializes a node that contains a basic string
    def initialize(data)
      @data = data.freeze #Freezes the data to protect against aliasing errors
      @length = data.length
      @depth = 0
    end

    def subtree(from, length)
      if length == @data.length
        self
      else
        self.class.new(@data.slice(from, length))
      end
    end

    def replace!(index, length, substr)
      left = if(index == 0)
        LeafNode.new(substr)
      else
        InteriorNode.new(
          LeafNode.new(@data.slice(0,index)),
          LeafNode.new(substr)
        )
      end

      if((index + length) < @data.length)
        InteriorNode.new(
          left,
          LeafNode.new(@data.slice(index + length, @data.length - (index + length)))
        )
      else
        left
      end
    end
	end
end