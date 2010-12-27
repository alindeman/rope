require 'rope'

describe "rope" do
  describe "#initialize" do
    it "can be constructed using the Rope constructor" do
      rope = Rope::Rope.new("testing123")
      rope.to_s.should == "testing123"
    end

    it "can be constructed using the to_rope method on a string" do
      rope = "testing123".to_rope
      rope.to_s.should == "testing123"
    end
  end

  describe "#+" do
    it "should allow concatenation of two Rope instances" do
      rope1 = "123".to_rope
      rope2 = "456".to_rope

      rope3 = rope1 + rope2
      rope3.to_s.should == "123456"

      # rope1 and rope2 should not have been affected
      rope1.to_s.should == "123"
      rope2.to_s.should == "456"
    end

    it "should allow concatenation of a Rope and a String" do
      rope = "123".to_rope
      string = "456"

      rope_concat = rope + string
      rope_concat.to_s.should == "123456"

      # rope and string should not have been affected
      rope.to_s.should == "123"
      string.should == "456"
    end

    it "should allow concatenation of many Rope instances" do
      rope_concat = ["123", "456", "789", "012"].inject(Rope::Rope.new) { |combined, str| combined += str.to_rope }
      rope_concat.to_s.should == "123456789012"
    end
  end

  describe "#dup" do
    it "should create a shallow copy" do
      rope = "123".to_rope
      rope_dupped = rope.dup

      rope.should == rope_dupped
      rope.should_not equal(rope_dupped)
    end
  end

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
