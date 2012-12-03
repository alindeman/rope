$Fib = Hash.new{ |h, n| h[n] = h[n - 1] + h[n - 2] }
$Fib[0] = 0
$Fib[1] = 1

CHUNK_SIZE = 16

#Ropes cache frequency counts of characters in the rope, Lazily evaluated
#Calling dup is faster than constantly creating new Hashes
$blank_freq_count = Hash.new{|h,c|
  h[c] = @left.freq_count[c] + @right.freq_count[c]}

class String

  alias at slice  
  alias slice_offsetted_section slice

  def shift(n=1)
    slice!(0)
  end

  def freq_count
    if @freq_count
      @freq_count
    else
      @freq_count = [0]*128
      each_byte {|c| @freq_count[c] += 1}
      @freq_count
    end
  end

  def width; 1; end
  def depth; 1; end

end


ObjectSpace.each_object(Class) do |klass|
  if klass <= IO and klass.private_method_defined? :initialize
    klass.class_eval <<-EOC
      alias old_initialize initialize
      def initialize(*args)
        @shifted_chars = 0
        old_initialize(*args)
      end
    EOC
  end
end

class IO

  def length
    if@length
      @length
    else
      seek(0, IO::SEEK_END)
      @length = pos
    end
  end

  #Pretends it's immutable
  def to_s
    if @text
      @text
    else
      $stdout.puts @shifted_chars
      $stdout.puts IO::SEEK_SET
      seek(@shifted_chars, IO::SEEK_SET)
      @text = read
    end
  end

  def shift
    seek(@shifted_chars, IO::SEEK_SET)
    @shifted_chars += 1
    getc
  end

  def freq_count
    to_s.freq_count
  end

  def slice_substring(str)
    if @text
      @text.slice(str)
    else #Avoid loading file into memory
      seek(@shifted_chars, IO::SEEK_SET)
      last_char = nil
      while true
        last_char = getc until last_char == str[0] or eof?
        return nil if eof?
        return str if read(str.length - 1) ==str[1..-1]
      end
    end
  end

  def slice_offsetted_section(start, length)
    seek(@shifted_chars + start, IO::SEEK_SET)
    read(length)
  end

  def at(ind)
    seek(@shifted_chars + ind, IO::SEEK_SET)
    getc
  end    

  def width; 1; end
  def depth; 1; end
end

class Rope
  attr_accessor :left, :right, :length, :freq_count

  def width; @left.width+@right.width; end
  def depth; [@left.width,@right.width].max+1; end

  def initialize(left="", right="")
    @left, @right = left, right
    @length = @left.length + @right.length
    @freq_count = $blank_freq_count.dup
   end


  def append(strope)
    #if @right.length < CHUNK_SIZE and strope.length < CHUNK_SIZE
    #  @right = Rope.new(@right,strope)
    #  @length = left.length + right.length
    #  @freq_count = $blank_freq_count.dup
    #else
      @left = Rope.new(@left,@right)
      @right = strope
      @left.freq_count = @freq_count
      @length = @left.length + @right.length
    #end
    self
  end
  alias << append

  def normalize
    ###Stack based algorithm removes the overhead of method calls,
    ###and the huge overhead of proc calls
    path = 0b0
    path_nodes = [self]
    cur_node = self

    seq = []
    while true
      if Rope === cur_node
        path = (path << 1) | 1
        cur_node = cur_node.left
        path_nodes.push(cur_node)
      else
        if path & 1 == 1
          path ^= 1 #flip the last bit
          path_nodes.pop
          cur_node = path_nodes.last.right
          path_nodes.push(cur_node)
        else
          break if path == 0 #Already visited all nodes
          until path&1 == 1
            path >>= 1
            path_nodes.pop
          end
          path ^= 1 #flip the last bit
          path_nodes.pop
          cur_node = path_nodes.last.right
          path_nodes.push(cur_node)
        end 
      end
      next if Rope === cur_node
      str = cur_node
      old_n = 0
      n = 0
      n += 1 until $Fib[n] > str.length
      n -= 1
      smallers = seq[0..n].reject{|o| o.nil?|| o.length == 0}
      until [] == smallers
       seq[old_n..n] = [nil]*(n-old_n+1)
       bal_rope = (smallers[1..-1]).inject(smallers[0]) {|r,s|
        Rope.new(s,r)}
      bal_rope = Rope.new(bal_rope, str)
      old_n = n
       n += 1 until $Fib[n] > bal_rope.length
       n -= 1
       str = bal_rope
       seq[n] = nil if n >= seq.length
       smallers = seq[old_n..n].reject{|o| o.nil? || o.length == 0}
      end
      seq[n] = str
    end
    seq.compact!
    seq[1..-1].inject(seq[0]) {|r,s| r = Rope.new(s,r)}
  end

  def to_s
    @left.to_s + @right.to_s
  end

  def slice(*args)
    if 2 == args.length and Fixnum === args[0]
      #modulus for negative start
      slice_offsetted_section(args[0] % @length, args[1])
    elsif 1 == args.length and Fixnum === args[0]
      index(args.first % @length)
    elsif 1 == args.length and Range === args[0]
      rng = args[0]
      slice_offsetted_section(rng.begin % @length,
        (rng.end - rng.begin + (rng.exclude_end? ? 0 : 1)) % @length)
    else
      slice_substring(args[0])
    end
  end

  def slice_offsetted_section(start, length)
    if start < @left.length
      if start + length < @left.length
        @left.slice_offsetted_section(start,length)
      else
        Rope.new(@left.slice_offsetted_section(start, @left.length - start),
          @right.slice_offsetted_section(0,
            length - (@left.length - start)))
      end
    else
      @right.slice_offsetted_section(start - @left.length, length)
    end
  end

  #def slice_substring(str)
  #  
  #end

  def index(offset)
    if offset < (left_len=@left.length)
      @left.at(offset)
    else
      @right.at(offset-left_len)
    end
  end
  alias at index

  def shift(n=1)
    ([0]*n).map do
      @length -= 1
      @left.length > 0 ? @left.shift : @right.shift
    end
  end
end

$x = 0
$y = 0

def sumupto(n)
  s = 0
  1.upto(n){|i| s+= i}
  s
end

def print_rope(tree,str=$stdout)
  arr = ([nil]*sumupto(tree.depth+1)).map{[nil] * (sumupto(tree.depth+1))}
  $y = 0
  $x = arr[0].length / 2
  coord_trav(tree) do |node|
    if Rope === node
      arr[$y][$x] = "/ \\"
    else
      arr[$y][$x] = node.to_s.inspect
    end
  end
  arr.each do |row|
    row.each do |cell|
      if cell == nil
        str.print "   "
      else
        str.print cell
      end
    end
    str.print "\n"
  end
  nil
end


def coord_trav(tree, &block)
  unless Rope === tree
    block.call(tree)
    return
  end
  $x -= tree.depth
  $y +=tree.depth
  coord_trav(tree.left,&block)
  $x +=tree.depth
  $y -=tree.depth
  block.call(tree)
  $x +=tree.depth
  $y +=tree.depth
  coord_trav(tree.right, &block)
  $x -=tree.depth
  $y -=tree.depth
end
