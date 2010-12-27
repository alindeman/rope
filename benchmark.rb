# Benchmarking code from
# http://www.rubyquiz.com/quiz137.html

# Compare:
# ruby benchmark.rb
# ruby -r lib/rope.rb -I lib benchmark.rb Rope::Rope

require 'benchmark'

#This code make a String/Rope of CHUNCKS chunks of text
#each chunck is SIZE bytes long. Each chunck starts with
#an 8 byte number. Initially the chuncks are shuffled the
#qsort method sorts them into ascending order.

puts 'preparing data...'
TextClass = eval(ARGV.shift || "String")

def qsort(text)
  return TextClass.new if text.length == 0
  pivot = text.slice(0,8).to_s.to_i
  less = TextClass.new
  more = TextClass.new
  offset = 8+SIZE
  while (offset < text.length)
    i = text.slice(offset,8).to_s.to_i
    (i < pivot ? less : more) << text.slice(offset,8+SIZE)
    offset = offset + 8+SIZE
  end
  print "*"
  return qsort(less) << text.slice(0,8+SIZE) << qsort(more)
end

SIZE = 512 * 1024
CHUNCKS = 128
CHARS = %w[R O P E]
data = TextClass.new
bulk_string =
  TextClass.new(Array.new(SIZE) { CHARS[rand(4)] }.join)
puts 'Building Text...'
build = Benchmark.measure do
  (0..CHUNCKS).sort_by { rand }.each do |n|
    data<< sprintf("%08i",n) << bulk_string
  end
  data.normalize if data.respond_to? :normalize
end
GC.start
sort = Benchmark.measure do
  puts "Sorting Text..."
  qsort(data)
  puts"\nEND"
end

puts "Build: #{build}Sort: #{sort}"
