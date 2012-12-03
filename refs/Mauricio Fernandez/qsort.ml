let (<<) = concat (* OCaml allows you to define new operators *)
let to_i = int_of_string
let to_s = to_string

let rec qsort' size = function
    Empty -> Empty
  | rope ->
      let pivot = to_i (to_s (sub 0 8 rope)) in
      let len = 8 + size in
      let less = ref Empty in
      let more = ref Empty in
      let off = ref len in
        while !off < length rope do
          let slice = sub !off len rope in
            if to_i (to_s (sub !off 8 rope)) < pivot then 
	      less := !less << slice
            else 
	      more := !more << slice;
            off := !off + len
        done;
        qsort' size !less << sub 0 len rope << qsort' size !more


let rec qsort size = function
    Empty -> Empty
  | rope ->
      let rec loop r pivot off len max less more =
        if off < max then begin
          if to_i (to_s (sub off 8 r)) < pivot then
            loop r pivot (off+len) len max (less << (sub off len r)) more
          else
            loop r pivot (off+len) len max less (more << (sub off len r))
        end else (less, more) in

      let pivot = to_i (to_s (sub 0 8 rope)) in
      let len = 8 + size in
      let less, more = loop rope pivot len len (length rope) Empty Empty in
        qsort size less << sub 0 len rope << qsort size more
