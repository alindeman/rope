module OCaml # Rope will be placed in this module
end

require "ocaml_rope.so"

module OCaml
  class Rope
    def self.new(str = "")
      case str
      when String; new_from_string str
      when Rope; str
      when ""; new_empty
      else new_from_string(str.to_str) rescue new_from_string(str.to_s)
      end
    end

    def prepend(rope)
      rope.append(self)
    end

    alias_method :append, :concat
    alias_method :<<, :append
  end
end
