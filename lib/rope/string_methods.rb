class String
  # Converts the String to a Rope
  def to_rope
    Rope::Rope.new(Rope::StringNode.new(self))
  end
end
