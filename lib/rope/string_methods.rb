class String
  # Converts the String to a Rope
  def to_rope
    Rope::Rope.new(self)
  end
end
