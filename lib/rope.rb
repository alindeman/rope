require 'forwardable'

require 'rope/concat_node'
require 'rope/string_node'

require 'rope/string_methods'

module Rope
  class Rope
    extend Forwardable

    def_delegators :@root, :to_s, :length, :rebalance!

    # Initializes a new rope
    def initialize(arg=nil)
      case arg
      when Node
        @root = arg
      when NilClass
        @root = StringNode.new("")
      else
        @root = StringNode.new(arg.to_s)
      end
    end

    # Concatenates this rope with another rope or string
    def +(other)
      Rope.new(concatenate(other))
    end

    # Tests whether this rope is equal to another rope
    def ==(other)
      to_s == other.to_s
    end

    # Creates a copy of this rope
    def dup
      Rope.new(root)
    end

    # Gets a slice of this rope
    def slice(*args)
      slice = root.slice(*args)

      case slice
      when Fixnum # slice(Fixnum) returns a plain Fixnum
        slice
      when Node, String # create a new Rope with the returned tree as the root
        Rope.new(slice)
      else
        nil
      end
    end
    alias :[] :slice

    protected
      # Root node (could either be a StringNode or some child of LeafNode)
      attr_reader :root

    private
      # Generate a concatenation node to combine this rope and another rope
      # or string
      def concatenate(other)
        # TODO: Automatically balance the tree if needed
        case other
        when String
          ConcatenationNode.new(root, StringNode.new(other))
        when Rope
          ConcatenationNode.new(root, other.root)
        end
      end
  end
end
