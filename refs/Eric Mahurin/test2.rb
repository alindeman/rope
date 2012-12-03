require 'benchmark'

#This code make a String/Rope of  CHUNKS chunks of text
#each chunck is SIZE bytes long.  Each chunck starts with
#an 8 byte number.  Initially the chuncks are shuffled the
#qsort method sorts them into ascending order.
#
#pass the name of the class to use as a parameter
#ruby -r rope.rb this_file [-immutable] Rope iterations

ARGV.shift if (immutable = (ARGV[0][0,2]=="-i"))
TextClass = eval(ARGV.shift || "String")
iterations = (ARGV.shift || 1).to_i

def qsort_immutable(text)
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
 return qsort_immutable(less) << text.slice(0,8+SIZE) << qsort_immutable(more)
end

def qsort_mutable(text)
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
 return qsort_mutable(less) << text.slice(0,8+SIZE) << qsort_mutable(more)
end

def build_mutable(bulk_text)
 data = TextClass.new
 (0..CHUNKS).sort_by { rand }.each do |n|
   data << TextClass.new(sprintf("%08i",n)) << bulk_text
 end
 data
end

def build_immutable(bulk_text)
 (0..CHUNKS).sort_by { rand }.inject(TextClass.new) do |data, n|
   data << TextClass.new(sprintf("%08i",n)) << bulk_text
 end
end

def mem
  vmsize = nil
  vmpeak = nil
  File.new("/proc/#{$$}/status").each_line { |line|
      if line=~/^VmSize\:\s+(.*)\n/
          vmsize = $1
      elsif line=~/^VmPeak\:\s+(.*)\n/
          vmpeak = $1
      end
  }
  [vmsize,vmpeak]
end

qsort = method(immutable ? :qsort_immutable : :qsort_mutable)
buildit = method(immutable ? :build_immutable : :build_mutable)

srand(123456789)
SIZE  = 512 * 1024
CHUNKS = 128
CHARS = %w[R O P E]
bulk_string = Array.new(SIZE) { CHARS[rand(4)] }.join
bulk_text = TextClass.new(bulk_string)

GC.start

puts "Initial: #{mem.join('   ')}"

data = nil
build = []
iterations.times {
 GC.start
 build << Benchmark.measure do
  data = buildit.call(bulk_text)
  data = data.normalize if data.respond_to? :normalize
 end
}
GC.start
build = build.inject { |min,cur| (cur.total<min.total) ? cur : min }
puts "Build: #{build.to_s.chop}   #{mem.join('   ')}"

# check that the indices add up
sum = 0
0.step(data.length-1, 8+SIZE) { |offset|
    sum += data.slice(offset,8).to_s.to_i
    bulk_data = data.slice(offset+8,SIZE).to_s
    warn("#{bulk_data[0,10]}.... != #{bulk_string[0,10]}....") if bulk_data!=bulk_string
}
expected_sum = (CHUNKS*(CHUNKS+1))/2
warn("#{sum}!=#{expected_sum}") if sum!=expected_sum

sorted_data = nil
sort = []
iterations.times {
 GC.start
 sort << Benchmark.measure do
  sorted_data = qsort.call(data)
 end
}
sort = sort.inject { |min,cur| (cur.total<min.total) ? cur : min }
puts "Sort: #{sort.to_s.chop}   #{mem.join('   ')}"

# check the sorted result
i = 0
0.step(sorted_data.length-1, 8+SIZE) { |offset|
    datai = sorted_data.slice(offset,8).to_s
    warn("#{datai.to_i}!=#{i}") if datai.to_i!=i
    bulk_data = sorted_data.slice(offset+8,SIZE).to_s
    warn("#{bulk_data[0,10]}.... != #{bulk_string[0,10]}....") if bulk_data!=bulk_string
    i += 1
}
warn("#{i}!=#{CHUNKS+1}") if i!=CHUNKS+1


