module Mahurin

class Rope
    include Enumerable
    # form a binary tree from two ropes (possibly sub-trees)
    def initialize(left,right)
        @left = left
        @right = right
        @llength = @left.length
        @length = @llength+@right.length
        @depth = [left.depth, right.depth].max+1
    end
    # number of elements in this rope
    def length
        @length
    end
    # depth of the tree (to help keep the tree balanced)
    def depth
        @depth
    end
    # left rope (not needed when depth==0)
    def left
        @left
    end
    # right rope (not needed when depth==0)
    def right
        @right
    end
    # appended rope (non-modifying)
    def +(other)
        # balance as an AVL tree
        balance = other.depth-@depth
        if balance>+1
            left = other.left
            right = other.right
            if left.depth>right.depth
                # rotate other to right before rotating self+other to left
                (self + left.left) + (left.right + right)
            else
                # rotate self+other to left
                (self + left) + right
            end
        elsif balance<-1
            if @right.depth>@left.depth
                # rotate self to left before rotating self+other to right
                (@left + @right.left) + (@right.right + other)
            else
                # rotate self+other to right
                @left + (@right + other)
            end
        else
            self.class.new(self, other)
        end
    end
    alias_method(:<<, :+)
    # slice of the rope
    def slice(start, len)
        return self if start.zero? and len==@length
        rstart = start-@llength
        return @right.slice(rstart, len) if rstart>=0
        llen = @llength-start
        rlen = len-llen
        if rlen>0
            @left.slice(start, llen) + @right.slice(0, rlen)
        else
            @left.slice(start, len)
        end
    end
    # element at a certain position in the rope
    def at(index)
        rindex = index-@llength
        if rindex<0
            @left.at(index)
        else
            @right.at(rindex)
        end
    end
    # iterate through the elements in the rope
    def each(&block)
        @left.each(&block)
        @right.each(&block)
    end
    # flatten the rope into a string (optionally starting with a prefix)
    def to_s(s="")
        @right.to_s(@left.to_s(s))
    end
end

EmptyRope = Object.new
class << EmptyRope
    include Enumerable
    def length
        0
    end
    def depth
        0
    end
    def +(other)
        other
    end
    alias_method(:<<, :+)
    def slice(start, len)
        self
    end
    def each
    end
    def to_s
        ""
    end
end

class StringRope
    include Enumerable
    def self.new(*args)
        if args.empty?
            EmptyRope
        else
            super
        end
    end
    def initialize(data)
        @data = data
    end
    def length
        @data.length
    end
    def depth
        0
    end
    def +(other)
        balance = other.depth
        if balance>1
            left = other.left
            right = other.right
            if left.depth>right.depth
                # rotate other to right before rotating self+other to left
                (self + left.left) + (left.right + right)
            else
                # rotate self+other to left
                (self + left) + right
            end
        else
            Rope.new(self, other)
        end
    end
    alias_method(:<<, :+)
    def slice(start, len)
        return self if start.zero? and len==@data.length
        # depend on ruby's COW mechanism to just reference the slice data
        self.class.new(@data.slice(start, len))
    end
    def at(index)
        @data[index]
    end
    def each(&block)
        @data.each_char(&block)
    end
    def to_s(s="")
        s.concat(@data.to_s)
    end
end

class ShortRope < Rope
    def +(other)
        if other.depth.zero? and @depth==1
            # @right+other may flatten
            @left + (@right + other)
        else
            super
        end
    end
    alias_method(:<<, :+)
end

class DenormalRope < Rope
    def +(other)
        self.class.new(self, other)
    end
    alias_method(:<<, :+)
    def normalize
        stack = []
        leaves { |node|
            while !stack.empty? and node.depth==stack.last.depth
                node = DenormalRope.new(stack.pop, node)
            end
            stack.push(node)
        }
        right = stack.pop
        while left=stack.pop
            right = left+right
        end
        right
    end
    def leaves(&block)
        @left.leaves(&block)
        @right.leaves(&block)
    end
end

class DenormalStringRope < StringRope
    def +(other)
        DenormalRope.new(self, other)
    end
    alias_method(:<<, :+)
    def normalize
        self
    end
    def leaves
        yield self
    end
end

class ShortStringRope < StringRope
    SHORT = 64
    def +(other)
        balance = other.depth
        if balance>1
            left = other.left
            right = other.right
            if left.depth>right.depth
                # rotate other to right before rotating self+other to left
                (self + left.left) + (left.right + right)
            else
                # rotate self+other to left
                (self + left) + right
            end
        elsif other.length==0
            # nothing to append, self will do
            self
        elsif @data.length+other.length<=SHORT
            # just merge the strings if the total length is short
            self.class.new(@data+other.to_s)
        else
            ShortRope.new(self, other)
        end
    end
end

class ArrayRope < StringRope
    def each(&block)
        @data.each(&block)
    end
end

class IORope < StringRope
    include Enumerable
    def initialize(io, start=0, length=(io.seek(0,IO::SEEK_END);io.pos-start))
        @io = io
        @start = start
        @length = length
    end
    def length
        @length
    end
    def slice(start, len)
        return self if start.zero? and len==@length
        # just reference a different part of the IO
        self.class.new(@io, @start+start, len)
    end
    def at(index)
        @io.pos = @start+index
        @io.getc
    end
    def each
        @io.pos = @start
        @length.times { yield @io.getc }
    end
    def to_s(s="")
        @io.pos = @start
        s.concat(@io.read(@length))
    end
end

class MutableStringRope
    include Enumerable
    def initialize(*args)
        @rope = StringRope.new(*args)
    end
    def rope
        @rope
    end
    def length
        @rope.length
    end
    def +(other)
        self.class.new(@rope+other.rope)
    end
    def <<(other)
        @rope = @rope+other.rope
        self
    end
    alias_method(:push, :<<)
    def >>(other)
        @rope = other.rope+@rope
        self
    end
    alias_method(:unshift, :<<)
    def slice(start, len)
        self.class.new(@rope.slice(start, len))
    end
    def slice!(start, len)
        self.class.new(@rope.slice(start, len))
    ensure
        start2 = start+len
        @rope = @rope.slice(0, start)+@rope.slice(start2, @rope.length-start2)
    end
    def at(index)
        @rope.at(index)
    end
    def delete_at(index)
        @rope.at(index)
    ensure
        start2 = index+1
        @rope = @rope.slice(0, index)+@rope.slice(start2, @rope.length-start2)
    end
    def insert(index, other)
        @rope = @rope.slice(0, index)+other.rope+@rope.slice(index, @rope.length-index)
        self
    end
    def shift(len=nil)
        if len
            begin
                self.class.new(@rope.slice(0, len))
            ensure
                @rope = @rope.slice(len, @rope.length-len)
            end
        else
            begin
                @rope.at(0)
            ensure
                @rope = @rope.slice(1, @rope.length-1)
            end
        end
    end
    def pop(len=nil)
        if len
            begin
                self.class.new(@rope.slice(@rope.length-len, len))
            ensure
                @rope = @rope.slice(0, @rope.length-len)
            end
        else
            begin
                @rope.at(@rope.length-1)
            ensure
                @rope = @rope.slice(0, @rope.length-1)
            end
        end
    end
    def [](start, *len)
        if len.empty?
            at(start)
        else
            slice(start, len[0])
        end
    end
    def []=(start, *len)
        val = len.pop
        if len.empty?
            start2 = start+1
            val = StringRope.new(""<<val)
            @rope = @rope.slice(0, start)+val+@rope.slice(start2, @rope.length-start2)
        else
            start2 = start+len
            @rope = @rope.slice(0, start)+val.rope+@rope.slice(start2, @rope.length-start2)
        end
    end
    def each(&block)
        @rope.each(&block)
    end
    def to_s(s="")
        @rope.to_s(s)
    end
end

end


