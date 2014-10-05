require 'forwardable'

require 'rope/basic_rope'

require 'rope/string_methods'

module Rope
  class Rope < BasicRope

    #Defines the kind of rope we're working with
    def data_type
      String
    end

    #
    # Special case for string Ropes since to_s is universal
    #
    def to_s
      to_primitive
    end
  end
end
