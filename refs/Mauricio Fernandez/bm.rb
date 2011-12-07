require 'benchmark'

#This code make a String/Rope of  CHUNKS chunks of text
#each chunck is SIZE bytes long.  Each chunk starts with
#an 8 byte number.  Initially the chunks are shuffled the
#qsort method sorts them into ascending order.
#
#pass the name of the class to use as a parameter
#ruby -r rope.rb this_file Rope

puts 'preparing data...'
TextClass = (ARGV.shift || "String").split(/::/).inject(Object){|s,x| s.const_get(x)}

def qsort(text)
  return TextClass.new if text.length == 0
  pivot = text.slice(0,8).to_s.to_i
  less = TextClass.new
  more = TextClass.new
  offset = 8+SIZE
  while (offset < text.length)
    i = text.slice(offset,8).to_s.to_i
    if i < pivot
      less <<= text.slice(offset,8+SIZE)
    else
      more <<= text.slice(offset,8+SIZE)
    end
    offset = offset + 8+SIZE
  end
  #print "*"
  return qsort(less) << text.slice(0,8+SIZE) << qsort(more)
end

SIZE  = 1 * 1024
CHUNKS = 32768
CHARS = %w[R O P E]
data = TextClass.new
bulk_string =
  TextClass.new(Array.new(SIZE) { CHARS[rand(4)] }.join)
puts 'Building Text...'
build = Benchmark.measure do
  (0..CHUNKS).sort_by { rand }.each do |n|
    data = data << TextClass.new(sprintf("%08i",n)) << bulk_string
  end
  data = data.normalize  if data.respond_to? :normalize
end
GC.start
sort = Benchmark.measure do
  puts "Sorting Text..."
  qsort(data)
  puts"\nEND"
end

puts "Build: #{build}Sort: #{sort}"

