require 'rope/basic_node'

module Rope
  # Specifies a leaf node that contains a basic string
	class LeafNode < BasicNode
    extend Forwardable

    def_delegators :@data, :slice
    def_delegator :@data, :slice

    # Initializes a node that contains a basic string
    def initialize(data)
      @data = data
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
	end
end