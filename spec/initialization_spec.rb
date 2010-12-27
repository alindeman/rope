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
end
