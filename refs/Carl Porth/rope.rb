require "rubygems"
require "facets"
require "kernel/with"
require "symbol/to_proc"

class String
  def shift
    return nil if empty?
    returning self[0].chr do
      self[0] = ""
    end
  end
end

class Rope
  attr_reader :left, :right, :length
  
  def Rope.new(*args)
    if args.size <= 2
      super
    else # build normalized rope
      mid = args.size / 2
      args[mid,2] = Rope.new(*args[mid,2])
      Rope.new(*args)
    end
  end
  
  def initialize(left="",right="")
    @left, @right = left, right
    @length = @left.length + @right.length
  end
  
  def replace(rope)
    initialize(rope.left,rope.right)
    self
  end

  # clean out empty strings
  def normalize
    replace(Rope.new(*flat_strings.reject(&:empty?)))
  end
  
  def to_s
    left.to_s + right.to_s
  end
  
  def append(str)
    replace(Rope.new(self.dup,str))
  end
  alias_method :<<, :append
  
  def prepend(str)
    replace(Rope.new(str,self.dup))
  end
  
  # slice with fixnums
  def slice(start,length)
    if start >= left.length
      right.slice(start-left.length,length)
    elsif start < left.length && (left.length-start) < length
      Rope.new(left.slice(start,left.length-start),
               right.slice(0,length-(left.length-start)))
    else
      left.slice(start,length)
    end
  end
  alias_method :[], :slice
  
  # shift off first letter
  def shift
    if letter = left.shift || right.shift
      @length -= 1
      letter
    else
      nil
    end
  end
  
  # find the index of a letter
  def index(letter,start=0)
    if start >= left.length
      left.length + right.index(letter,start-left.length)
    else
      left.index(letter,start) || left.length + right.index(letter)
    end
  rescue
    nil
  end
  
  # TODO implement rest of methods, cheat for now
  def method_missing(method, *args, &block)
    result = to_s.send(method, *args, &block)
    if result.is_a?(String)
      if method.to_s =~ /!$/
        replace(Rope.new(result))
      else
        Rope.new(result)
      end
    else
      result
    end
  end
  
protected

  # traverse the tree
  def traverse(&block)
    @left.is_a?(Rope) ? @left.traverse(&block) : block.call(@left)
    @right.is_a?(Rope) ? @right.traverse(&block) : block.call(@right)
  end

  # collect all the flat strings
  def flat_strings
    returning [] do |ary|
      traverse { |str| ary << str }
    end
  end

end