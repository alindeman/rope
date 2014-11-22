require 'forwardable'

require 'rope/basic_rope'

require 'rope/string_methods'

module Rope
  Rope = BasicRope.rope_for_type(String) do
    #
    # Special case for string Ropes since to_s is universal
    #
    def to_s
      to_primitive
    end
  end
end
