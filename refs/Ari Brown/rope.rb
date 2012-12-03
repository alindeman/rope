#!/usr/local/bin/ruby
#
#  Created by me on 2007-09-05.
#  Copyright (c) 2007. All pwnage reserved.

class String
  alias_method(:old_plus, :+)
  def +(other)
    self + other.to_s if other.is_a? Rope
    self.old_plus(other)
  end

  def to_rope
    Rope.new(self)
  end
  alias_method(:to_r, :to_rope)
end

class Rope
  attr_reader :strands
  attr_reader :length
  attr_reader :depth
  attr_reader :segments

  def initialize(strand, chunk_size=15)
    CHUNK_SIZE = chunk_size
    raise "What are you doing?!" if strands.nil?
    strand = strand.to_s if strands.is_a? Integer
    @strands = check_size(strand)
    @depth = 1
    @segments = 0
    calc_info
  end

  def update(&b)
    instance_eval(b)
    calc_info
    conform
  end

  def calc_info
    @strands.each { |s| @length += s.length }
    @strands.each { |s| @depth += s.depth if s.is_a? Rope}
    @strands.each { |s| @segments += 1}
  end

  def check_size(strand)
    return if strand.nil?
    if strand.size > CHUNK_SIZE
      start, finish = 0, (-CHUNK_SIZE + 1)
      strands = []
      until strand[start] == nil
        strands << strand.slice(start, CHUNK_SIZE)
        start = finish
        finish += CHUNK_SIZE
      end
      puts strands
      return strands
    end
    return [strand]
  end

  def conform
    @strands = check_size(to_s)
  end

  def append(*strings)
    update do
      raise "What are you doing?!" if strings.nil?
      strings.each { |s| @strands << s}
    end
  end

  alias_method(:<<, :append)

  def prepend(*strings)
    update do
      old_strands = @strands
      strings.each { |s|
        s = s.to_s if s.is_a? Integer
        @strands = s
      }
      @strands << old_strands
    end
  end

  def flatten
    old_strands, @strands = @strands, []
    update do
      @strands.each do |s|
        if s.is_a? Rope
          s.strands.map { |s| @strands << s }
        elsif not s.nil?
          @strands << s
        end
      end
    end
    self
  end

  def +(other)
    update do
      if other.is_a? Rope
        @strands += other.strands
      elsif not other.nil?
        @strands += other.to_s
      end
    end
  end

  alias_method(:add, :+)
  alias_method(:push, :+)

  def to_s
    case @strands
    when 0: ""
    else
      return (@strands * "")
    end 
  end

  def slice(here, length=nil)
    begin
      return nil if here < 0 || here > self.length
      return to_s.slice(start, length||0) if here.is_a? Regexp
      location = here%CHUNK_SIZE
      car = here/CHUNK_SIZE
      left = start
      ret = ""
      if here < 0 || here > self.length
        nil
      elsif !length
        @segments.detect { |s| (start -= s.length) < 0 }.slice(start)
      elsif !length && start.is_a? Range
        length = here.last - here.first - (exclude_end? ? 1 : 0)
        here = here.first
      elsif true
        while @strands[car]
          thing = @strands[car][0..-1]
          thing.each_byte { |l|
            ret << l.chr
            left -= 1
            break if left == 0
          }
          car += 1 if left != 0
        end
        return ret
      end
    rescue
      to_s.slice(here, length)
    end
  end

  def [](here)
    location = here%CHUNK_SIZE
    car = here/CHUNK_SIZE
    train_car = @strands[car]
    return train_car[location].chr
  end
  
  def method_missing(m, *args, &block)
    if "".responds_to?(m) && m =~ /^string_(.+)/
      ret = to_s.__send__($1, *args, &block)
      if ret.is_a? String
        ret = Rope.new(ret)
      end
    end
    ret
  end