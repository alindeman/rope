
require 'rope'

describe "rope" do
  describe "#dup" do
    it "should create a shallow copy" do
      rope = "123".to_rope
      rope_dupped = rope.dup

      rope.should == rope_dupped
      rope.should_not equal(rope_dupped)
    end
  end
end
