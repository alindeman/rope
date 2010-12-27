require 'forwardable'

module Rope
  # Specifies a generic leaf node
  class LeafNode
    extend Forwardable

    # Specifies the data for this leaf node.  For some types of nodes, this
    # attribute may be generated on-the-fly.
    attr_reader :data

    def_delegators :data, :length, :slice, :[]

    # Gets the depth of the tree with this node as the root.  Since this is
    # a leaf node, the depth is 0.
    def depth
      0
    end

    # Gets the string data for the node
    def to_s
      data
    end
  end
end

