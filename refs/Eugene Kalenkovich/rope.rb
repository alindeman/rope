class NilClass
  def length; 0; end
end

class String
  def shift
    return nil if empty?
    res=self[0]
    self[0]=""
    res
  end
end

class Rope
  attr_reader :length, :left, :right

  def initialize(left=nil,right=nil,dup=true)
    @left = left ? left.kind_of?(Rope)&&dup ? left.dup : left : nil
    @right = right ? right.kind_of?(Rope)&&dup ? right.dup : right : nil
    @length=left.length+right.length
  end

  def append(what, dup=true)
    len=what.length
    if (len>0)
      @left=self.dup if @right.length>0
      @right=what.kind_of?(Rope)&&dup ? what.dup : what
      @length+=len
    end
    self
  end

  alias << append

  def prepend(what, dup=true)
    len=what.length
    if (len>0)
      @right=self.dup if @left.length>0
      @left=what.kind_of?(Rope)&&dup ? what.dup : what
      @length+=len
    end
    self
  end

  def to_s
    @left.to_s + @right.to_s
  end

  def [](i)
    return i.match(self.to_s)[0] if i.kind_of? Regexp
    if i.kind_of? Range
      pos,last=i.first,i.last
      pos = @length+pos if pos<0
      last = @length+last if last<0
      return nil if pos<0 || last<0
      return slice(pos,last-pos+1)
    end
    i = @length+i if i<0
    return nil if i<0 || i>@length-1
    llen = @left.length
    i<llen ? @left[i] : @right[i-llen]
  end

  def []=(i,val)
    #fixnum only
    i = @length+i if i<0
    ""[i]=0 if i<0 || i> @length-1
    @length+=val.length-1
    llen = @left.length
    i<llen ? @left[i]=val : @right[i-llen]=val
  end

  def slice(pos,len)
    return pos.match(self.to_s)[len] if pos.kind_of? Regexp
    pos = @length+pos if pos<0
    return nil if pos<0 || len<0 || pos>@length-1
    llen = @left.length
    return @left.slice(pos,len) if pos+len<=llen || ! @right
    return @right.slice(pos-llen, len) if pos>=llen
    Rope.new(@left.slice(pos,llen-pos),@right.slice(0,len+pos-llen))
  end

  def shift
    return nil if @length==0
    @length-=1
    res = @left.length>0 ? @left.shift : @right.shift
    @left=nil if @left.length==0
    @right=nil if @right.length==0
    res
  end

  def normalize
    r=Rebalancer.new(@length)
    self.traverse { |str| r.append(str) }
    @left, @right=r.get_ropes
    self
  end

  def traverse(&blck)
    @left.kind_of?(String) ? yield( @left) : @left.traverse(&blck) if @left
    @right.kind_of?(String) ? yield( @right) : @right.traverse(&blck) if @right
  end

end

class Rebalancer
  def initialize len
    @limits=[1,2]
    @slots=[]
    n=2
    @limits<< n = @limits[-2] + @limits[-1] while n<len
  end

  def append str
    @slots[0] = @slots[0] ? Rope.new( @slots[0],str, false) : str
    i=0
    while @slots[i].length>@limits[i]
      @slots[i+1] = @slots[i+1] ? Rope.new( @slots[i+1],@slots[i],false) : @slots[i]
      @slots[i] = nil
      i+=1
    end
  end

  def get_ropes
    @slots.compact!
    (@slots.length-1).times { |i|
      @slots[i+1]=@slots[i+1] ? Rope.new(@slots[i+1],@slots[i],false) : @slots[i]
      @slots[i]=nil
      i+=1
    }
    [@slots[-1].left,@slots[-1].right]
  end
end
