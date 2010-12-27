require 'rope/leaf_node'

module Rope
  # Specifies a leaf node that contains a basic string
  class StringNode < LeafNode
    # Initializes a node that contains a basic string
    def initialize(string)
      @data = string
    end

    def subtree(from, length)
      return self if length == @data.length

      StringNode.new(@data.slice(from, length))
    end
  end
end
