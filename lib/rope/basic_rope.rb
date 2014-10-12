require 'rope/leaf_node'
require 'rope/interior_node'

module Rope
	# BasicRope is a data-type-agnostic Rope data structure. The data type is
	# typically a string but can be anything that implements the following
	# methods:
	#
	# * length - integer length of a unit of the data type
	# * slice - break a unit of the data type into two pieces on an index boundary
	#x * + - join two pieces of the data type together
	# * concat - append one object of the type to another (mutative)
	#
	# BasicRopes may also be sparse if the data store supports: 
	#
	# * TODO
	#
	class BasicRope
    extend Forwardable

    def self.rope_for_type(type, &block)
    	Class.new(self) do
    		define_method :primitive_type do
    			type
    		end
    		
    		class_eval &block if block_given?
    	end
    end

    # Initializes a new rope
    def initialize(arg=nil)
      case arg
      when BasicNode
        @root = arg
      when NilClass
        @root = LeafNode.new(primitive_type.new)
      when primitive_type
      	@root = LeafNode.new(arg)
      when self.class, InteriorNode
      	@root = LeafNode.new(arg.to_primitive)
      else
        raise ArgumentError, "#{arg} is not a #{primitive_type}"
      end
    end

    def_delegators :@root, :to_primitive, :length, :rebalance!, :segment

    # Concatenates this rope with another rope or string
    def +(other)
      self.class.new(concatenate(other))
    end

    # Tests whether this rope is equal to another rope
    def ==(other)
      to_primitive == (BasicRope === other ? other.to_primitive : other)
    end

    # Creates a copy of this rope
    def dup
      self.class.new(root)
    end

    # Gets a slice of this rope
    def slice(*args)
      slice = root.slice(*args)

      case slice
      when Fixnum # slice(Fixnum) returns a plain Fixnum
        slice
      when BasicNode, primitive_type # create a new Rope with the returned tree as the root
        self.class.new(slice)
      else
        nil
      end
    end
    alias :[] :slice

    def []=(index, length=1, rhs)
    	@root = @root.replace!(index, length, rhs)
    	self
    end

    protected

    # Root node (could either be a LeafNode or some child of LeafNode)
    attr_reader :root

    private

    # Generate a concatenation node to combine this rope and another rope
    # or string
    def concatenate(other)
      # TODO: Automatically balance the tree if needed
      case other
      when primitive_type
        InteriorNode.new(root, LeafNode.new(other))
      when Rope
        InteriorNode.new(root, other.root)
      end
    end

    def primitive_type
    	raise NotImplementedError, "This method must return the data type stored in the rope"
    end

	end
end