
require 'rope'

describe "rope" do
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
end
