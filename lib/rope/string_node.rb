require 'rope/leaf_node'

module Rope
  # Specifies a leaf node that contains a basic string
  class StringNode < LeafNode
    # Initializes a node that contains a basic string
    def initialize(string)
      @data = string
    end
  end
end
