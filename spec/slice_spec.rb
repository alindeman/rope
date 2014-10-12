
require 'rope'

describe Rope::Rope do
  describe "#slice" do
    context "Fixnum, Fixnum" do # slice(Fixnum, Fixnum)
      it "should return a slice for a Rope instance created with a String" do
        rope = "12345".to_rope
        rope_slice = rope.slice(0, 2)

        rope_slice.to_s.should == "12"
        rope_slice.class.should == Rope::Rope
      end

      it "should return a slice for a Rope instance created by concatenating other Rope instances" do
        rope = ["123", "456", "789", "012"].inject(Rope::Rope.new) { |combined, str| combined += str.to_rope }
        rope_slice = rope.slice(2, 6)

        rope_slice.to_s.should == "345678"
        rope_slice.class.should == Rope::Rope
      end

      it "should return a slice when given a negative index" do
        rope = ["123", "456", "789", "012"].inject(Rope::Rope.new) { |combined, str| combined += str.to_rope }
        rope_slice = rope.slice(-8, 6)

        rope_slice.to_s.should == "567890"
        rope_slice.class.should == Rope::Rope
      end

      it "should return nil when given a negative length" do
        "1234567".to_rope.slice(2, -1).should be_nil
      end

      it "should return an empty string when given a 0 length" do
        "1234567".to_rope.slice(2, 0).to_s.should be_empty
      end
    end

    context "Fixnum" do # slice(Fixnum)
      it "should return the character value of the character at the given position" do
        rope = ["123", "456", "789", "012"].inject(Rope::Rope.new) { |combined, str| combined += str.to_rope }

        rope.slice(0).should == ?1
        rope.slice(3).should == ?4
        rope.slice(7).should == ?8
      end

      it "should return a single character string" do
        "12345".slice(0).should == "1"
      end
    end

    context "Range" do # slice(Range)
      it "should return a slice for a Rope when given a Range" do
        rope = ["123", "456", "789", "012"].inject(Rope::Rope.new) { |combined, str| combined += str.to_rope }

        rope.slice(0..2).to_s.should == "123"
        rope.slice(0...2).to_s.should == "12"
      end

      it "should return a slice for a Rope when given a Range that exercises edge cases" do
        rope = ["123", "456", "789", "012"].inject(Rope::Rope.new) { |combined, str| combined += str.to_rope }

        rope.slice(5..5).to_s.should == "6"
        rope.slice(5...5).to_s.should == ""
        rope.slice(0...0).to_s.should == ""
      end

      it "should return a slice for a Rope when given a Range that contains negative indices" do
        rope = ["123", "456", "789", "012"].inject(Rope::Rope.new) { |combined, str| combined += str.to_rope }

        rope.slice(-4..-2).to_s.should == "901"
        rope.slice(-4...-2).to_s.should == "90"
      end

      it "should return an empty Rope when given a Range where the first index is greater than the last index" do
        "1234567".slice(4..2).to_s.should be_empty
        "1234567".slice(-2..-4).to_s.should be_empty
      end
    end
  end
end
