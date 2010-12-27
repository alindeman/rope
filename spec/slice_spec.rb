
require 'rope'

describe "rope" do
  describe "#slice" do
    it "should correctly return a slice for a Rope instance created with a String" do
      rope = "12345".to_rope
      rope_slice = rope.slice(0, 2)

      rope_slice.to_s.should == "12"
    end

    it "should correctly return a slice for a Rope instance created by concatenating other Rope instances" do
      rope = ["123", "456", "789", "012"].inject(Rope::Rope.new) { |combined, str| combined += str.to_rope }
      rope_slice = rope.slice(2, 6)

      rope_slice.to_s.should == "345678"
    end

    it "should correctly return a slice when given a negative index" do
      rope = ["123", "456", "789", "012"].inject(Rope::Rope.new) { |combined, str| combined += str.to_rope }
      rope_slice = rope.slice(-8, 6)

      rope_slice.to_s.should == "567890"
    end

    it "should return nil when given a negative length" do
      "1234567".to_rope.slice(2, -1).should be_nil
    end

    it "should return an empty string when given a 0 length" do
      "1234567".to_rope.slice(2, 0).to_s.should be_empty
    end
  end
end
