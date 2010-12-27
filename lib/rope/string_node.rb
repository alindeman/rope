require 'forwardable'

require 'rope/node'

module Rope
  # Specifies a leaf node that contains a basic string
  class StringNode < Node
    extend Forwardable

    def_delegators :@data, :slice
    def_delegator :@data, :slice, :char_at

    # Initializes a node that contains a basic string
    def initialize(string)
      @data = string
      @length = string.length
      @depth = 0
    end

    def subtree(from, length)
      if length == @data.length
        self
      else
        StringNode.new(@data.slice(from, length))
      end
    end
  end
end
