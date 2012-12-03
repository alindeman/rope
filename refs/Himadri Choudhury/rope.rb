#!/usr/bin/env ruby

CHUNK_SIZE = 16

class Rope
    attr_reader :length, :left, :right, :str
    def initialize(str="",left=nil,right=nil)
        @str = str
        @left = left
        @right = right

        @length = str.length
        @length += left.length if left != nil
        @length += right.length if right != nil

    end

    def isleaf(node)
        return (node.left == nil and node.right == nil)
    end

    # append(): Returns a rope after appending the rope (or string) pointed to by right. 
    def append(right)
        right = Rope.new(right) unless right.kind_of?(Rope)
        left = self
        
        # If right rope is a leaf then try to merge with a short flat string on the left rope as long as the 
        # resulting concatenated string doesn't exceed CHUNK_SIZE size
        if isleaf(right) 
            if isleaf(left) and (right.length + left.length <= CHUNK_SIZE or left.length == 0)
                @str = left.str + right.str
                @left = nil
                @right = nil
                @length = @str.length
                return self
            elsif !isleaf(left) and isleaf(left.right) and left.right.length + right.length <= CHUNK_SIZE
                @right.str += right.str
                @length += right.str.length
                return self
            end
        end
        @length += right.length
        if @left == nil
            @left = Rope.new(@str)
            @str = ""
        end
        if @right == nil
            @right = right
        else
            @left = Rope.new("",@left,@right)
            @right = right
        end
        return self
    end

    alias << append

    # prepend(): Returns a rope after prepending the rope (or string) pointed to by left.
    def prepend(left)
        left = Rope.new(left) unless left.kind_of?(Rope)
        right = self
        # If left rope is a leaf then try to merge with a short flat string on the right rope as long as the 
        # resulting concatenated string doesn't exceed CHUNK_SIZE size
        if isleaf(left) 
            if isleaf(right) and (right.length + left.length <= CHUNK_SIZE or right.length == 0)
                @str = left.str + right.str
                @left = nil
                @right = nil
                @length = @str.length
                return self
            elsif !isleaf(right) and isleaf(right.left) and right.left.length + left.length <= CHUNK_SIZE
                @left.str = left.str + @left.str
                @length += left.str.length
                return self
            end
        end
        @length += left.length
        if @right == nil
            @right = Rope.new(@str)
            @str = ""
        end
        if @left == nil
            @left = left
        else
            @right = Rope.new("",@left,@right)
            @left = left
        end
        return self
    end

    def to_s
        left.to_s + str + right.to_s
    end

    # slice(): Returns a Rope which represents a string starting from offset "start" with length "len"
    # Allows for negative start and len
    def slice(start,len=1)
        return nil if len == 0
        start = 0 if start < 0
        if isleaf(self)
            ret = @str.slice(start,len)
            ret = "" if ret == nil
            return Rope.new(ret)
        end

        left_len = @left == nil ? 0 : @left.length
        left = Rope.new("")
        if @left != nil
            if start == 0 and len >= @left.length
                left = @left.clone
            elsif start < left_len
                left = @left.slice(start,len)
            end
        end

        right_len = @right == nil ? 0 : @right.length
        if @right != nil
            if start < left_len and start + len >= left_len + right_len
                right = @right.clone
            else
                right = @right.slice(start-left_len,len-left.length)
            end
        end

        if left != nil and right != nil
            return left << right
        elsif left != nil
            return left
        else
            return right
        end
    end

    # normalize(): rebalances the tree
    def merge(arr)
        if isleaf(self)
            acc = Rope.new
            pos0 = 1
            pos1 = 2
            n = 0
            while not (pos0 <= @str.length and @str.length < pos1)
                if arr[n] != nil
                    acc.prepend(arr[n])
                    arr[n] = nil
                end
                pos1, pos0 = pos0 + pos1, pos1
                n += 1
            end
            acc << self
            while not (pos0 <= acc.length and acc.length < pos1) or arr[n] != nil
                if arr[n] != nil
                    acc.prepend(arr[n])
                    arr[n] = nil
                end
                pos1, pos0 = pos0 + pos1, pos1
                n += 1
            end
            arr[n] = acc.clone
        end
        @left.merge(arr) if @left != nil
        @right.merge(arr) if @right != nil
    end
    def normalize
        arr = []
        merge(arr)
        arr.length.times do |i|
            n = arr.length-1-i
            return arr[n] if arr[n] != nil
        end
    end


    # char_at(): returns the character at position given by the 0 based offset off
    def char_at(off)
        if off.abs >= @length
            return ""
        end
        off = (off + @length) % @length
        if isleaf(self)
            return str.slice(off,1)
        elsif off < left.length
            return @left.char_at(off)
        else 
            return @right.char_at(off-@left.length)
        end
    end

    # shift(): removes and returns the first del character(s) from the rope
    def shift(del=1)
        del = @length if del > @length
        rem = del
        ret = ""
        if isleaf(self)
            ret += @str.slice(0,rem)
            @str.slice!(0,rem)
        end
        if @left != nil
            if rem > @left.length
                rem -= @left.length
                ret += @left.shift(@left.length)
            else
                ret = @left.shift(rem)
                rem = 0
            end
            if @left.length <= 0
                @left = nil
            end
        end
        if @right != nil and rem > 0
            ret += @right.shift(rem)
            rem = 0
            if @right.length <= 0
                @right= nil
            end
        end
        @length -= del
        return ret
    end
end