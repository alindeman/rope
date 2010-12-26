require 'rope'

describe "rope" do
  describe "initialization" do
    it "by default, is constructed with an empty string" do
      rope = Rope::Rope.new
      # TODO: Test to_s is ""
    end

    it "can be constructed by specifying an initial string value" do
      rope = Rope::Rope.new "testing123"
      # TODO: Test to_s is "testing123"
    end

    it "can be constructed by using the to_rope method on a string" do
      rope = "testing123".to_rope
      # TODO: Test to_s is "testing123"
    end
  end
end
