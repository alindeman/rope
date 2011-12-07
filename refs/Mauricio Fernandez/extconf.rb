EXT_NAME = "ocaml_rope"
OCAML_PACKAGES = %w[]
CAML_LIBS = %w[]
CAML_OBJS = %w[]
CAML_FLAGS = ""
CAML_INCLUDES = []

require 'rocaml'

Interface.generate("ocaml_rope") do |iface|
  def_class("Rope", :under => "OCaml") do |c|
    rope = c.abstract_type

    fun "empty", UNIT => rope, :as => "new_empty"
    fun "of_string", STRING => rope, :as => "new_from_string"

    method "sub", [rope, INT, INT] => rope, :as => "slice"
    method "concat", [rope, rope] => rope
    method "length", rope => INT
    method "get", [rope, INT] => INT
    method "to_string", rope => STRING, :as => "to_s"
  end
end

require 'rocaml_extconf'
