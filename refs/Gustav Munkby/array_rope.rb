class Array
  def upper_bound(value)
    lo, hi = 0, size-1
    while lo <= hi
  	  mid = (lo + hi) / 2
  	  if value >= at(mid)
	      lo = mid + 1
  	  else
	      hi = mid - 1
  	  end
  	end
    lo
  end
end

class ArrayRope
  attr_reader :segments
  def initialize(*segments)
    raise segments.inspect if segments.any? { |s| s.nil? }
    @segments = segments.map { |s| s.dup }
    compute_offsets
  end

  def compute_offsets
    l = 0
    @offsets = @segments.map { |s| l += s.length }
    @offsets.unshift 0    
  end

  def length
    @offsets.last
  end
  alias :size :length
  def empty?
    @segments.empty?
  end

  def to_s
    case @segments.size
    when 0; ""
    when 1; @segments.first.dup
    else
      # When converting to a string, we must do the expensive
      # concatenation, so lets hijack that information and use the
      # new string internally as well.
      s = (@segments * "")
      @segments, @offsets = [s], [0,s.length]
      s.dup
    end
  end
  
  def method_missing(m, *args, &block)
    # Make sure we handle remaining string methods accordingly
    if "".respond_to?(m)
      s = to_s
      r = s.__send__(m, *args, &block)

      # Guess that this is the right thing to do
      if r.equal? s
        r = self 
      elsif r.is_a? String
        r = ArrayRope.new r
      end

      # The method might change the contents of the string
      replace s

      r
    else
      super(m, *args, &block)
    end
  end
  
  def responds_to?(m)
    # Make sure we handle remaining string methods accordingly
    super || "".responds_to?(m)
  end
  
  def append(*segments)
    segments.each do |s|
      if s.is_a? ArrayRope
        append *s.segments
      elsif !s.empty?
        @segments << s.dup
        @offsets << @offsets.last + s.length
      end
    end
    self
  end
  alias :<< :append
  def prepend(*segments)
    segments.each do |s|
      if s.is_a? ArrayRope
        prepend *s.segments
      elsif !s.empty?
        @segments.unshift s.dup
        compute_offsets
      end
    end
    self
  end
  
  def slice(start,length=nil)
    return to_s.slice(start, length||0) if start.is_a? Regexp
    return index(start) if start.is_a? String
    if !length && start.is_a?(Range)
      length = start.last - start.first - (exclude_end? ? 1 : 0)
      start = start.first
    end
    start = self.length + start if start < 0
    if start < 0 || start > self.length
      nil
    elsif !length
      @segments.detect { |s| (start -= s.length) < 0 }.slice(start)
    else
      index = @offsets.upper_bound(start) - 1
      rope = ArrayRope.new(
        @segments.at(index).slice(start - @offsets.at(index), length))
      remain = length - rope.length
      while remain > 0 && (index += 1) < @segments.length
        rope << @segments.at(index).slice(0, remain)
        remain = length - rope.length
      end
      rope
    end
  end
  alias :[] :slice
  
  def dup; ArrayRope.new(*@segments); end
  alias :clone :dup
  
  def +(other); dup << other; end

  include Enumerable
  def each &block
    last = nil
    @segments.each do |s|
      s.each do |l|
        if l[-1] == ?\n
          yield(last ? "#{last}#{l}" : l)
          last = nil
        else
          last = "#{last}#{l}"
        end
      end
    end
    yield last if last
    self
  end
  def each_byte &block
    @segments.each { |s| s.each_byte &block }
    self
  end

  include Comparable
  %w[<=> casecmp].each do |m|
    module_eval <<-EOM
      def #{m}(other)
        result = 0
        @segments.zip(@offsets) do |segment,offset|
          result = other.slice(offset, segment.length).#{m}(segment)
          break if result != 0
        end
        -result
      end
    EOM
  end
  def ==(other)
    @offsets.last == other.length && (self <=> other) == 0
  end
  alias :eql? :==
  
  def hash; @segments.inject(0) { |h, s| h + s.hash }; end

  def replace str
    @segments, @offsets = [], [0]
    append str
  end

  %w[downcase upcase capitalize swapcase].each do |m|
    module_eval <<-EOM
      def #{m}!
        @segments.inject(nil) do |r,s|
          s.#{ m }! ? self : r
        end
      end
    EOM
  end
  
  def rstrip!
    while @segments.last.rstrip!
      if @segments.last.empty?
        @segments.pop
        @offsets.pop
      else
        @offsets[-1] = @offsets[-2] + @segments[-1].length
        return self
      end
    end
  end

  def lstrip!
    while @segments.first.lstrip!
      if @segments.first.empty?
        @segments.shift
      else
        compute_offsets
        return self
      end
    end
  end

  def strip!
    rstrip! ? lstrip! || self : lstrip!
  end

  def chop!
    unless @segments.empty?
      if @segments.last.chop!
        if @segments.last.empty?
          @segments.pop
          @offsets.pop
        else
          @offsets[-1] -= 1
        end
        return self
      end
    end
  end
  
  def chomp!(sep=$/)
    unless @segments.empty?
      if @segments.last.chomp!(sep)
        if @segments.last.empty?
          @segments.pop
          @offsets.pop
        else
          @offsets[-1] -= 1
        end
        return self
      end
    end
  end
  
  def next!
    (@segments.length-1).downto(0) do |i|
      s = @segments.at(i)
      n = s.next
      r = n.length > s.length
      s.replace n
      s.slice!(-1) if r && i > 0
      break unless r
    end
    self
  end

  %w[downcase upcase capitalize swapcase lstrip rstrip strip chop chomp next].each do |m|
    module_eval <<-EOM
      def #{m}strip
        d = dup
        d.#{m}strip!
        d
      end
    EOM
  end
end
