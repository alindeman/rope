require 'rope'

describe Rope::Rope do
	describe "[<Fixnum>]=" do
		(1..4).each do |segments|
			rope_len = segments.times.collect { |i| i + 1 }.reduce(0, :+)

			context "a #{segments} segment rope (length #{rope_len})" do
				#Makes a rope of successive pieces, each one longer than the previous
				subject {
					segments.times.collect { |i| i + 1 }.reduce("".freeze.to_rope) do |rope, i|
						rope += (rope.length..(rope.length + i)).collect { |x| (x.to_i % 10).to_s.freeze }.join
					end
				}

				(0..2).each do |replacement_len|
					context "a #{replacement_len} length replacement str" do
						let(:replacement) { ('a'..'z').to_a[0,replacement_len].join }

						(0..rope_len).each do |offset|
							(0..2).each do |replace_len|
								it "replaces a substring of length #{replace_len} at offset #{offset} with a string" do
									as_string = subject.to_s.dup

									as_string[offset, replace_len] = replacement
									subject[offset, replace_len]   = replacement

									expect(subject.to_s).to eq(as_string)
								end
							end
						end
					end
				end
			end
		end

		it "doesn't alias" do
			r1 = "foo".to_rope + "bar" + "baz"
			r2 = r1.dup

			r2[0,3] = "baz"

			expect(r2).not_to eq(r1)
		end
	end
end