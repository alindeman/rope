type t =
    Empty
  (* left, left size, right, right size, height *)
  | Concat of t * int * t * int * int
  | Leaf of string

type forest_element = { mutable c : t; mutable len : int }

let str_append = (^)
let empty_str = ""
let string_of_string_list l = String.concat "" l

let max_height = 48

let leaf_size = 256

exception Out_of_bounds

let empty = Empty

(* by construction, there cannot be Empty or Leaf "" leaves *)
let is_empty = function Empty -> true | _ -> false

let height = function
    Empty | Leaf _ -> 0
  | Concat(_,_,_,_,h) -> h

let rec length = function
    Empty -> 0
  | Leaf s -> String.length s
  | Concat(_,cl,_,cr,_) -> cl + cr

let make_concat l r =
  let hl = height l and hr = height r in
  let cl = length l and cr = length r in
    Concat(l, cl, r, cr, if hl >= hr then hl + 1 else hr + 1)

let min_len =
  let fib_tbl = Array.make max_height 0 in
  let rec fib n = match fib_tbl.(n) with
      0 ->
        let last = fib (n - 1) and prev = fib (n - 2) in
        let r = last + prev in
        let r = if r > last then r else last in (* check overflow *)
          fib_tbl.(n) <- r; r
    | n -> n
  in
    fib_tbl.(0) <- leaf_size + 1; fib_tbl.(1) <- 3 * leaf_size / 2 + 1;
    Array.init max_height (fun i -> if i = 0 then 1 else fib (i - 1))

let max_length = min_len.(Array.length min_len - 1)

let concat_fast l r = match l with
    Empty -> r
  | Leaf _ | Concat(_,_,_,_,_) ->
      match r with
          Empty -> l
        | Leaf _ | Concat(_,_,_,_,_) -> make_concat l r

(* based on Hans-J. Boehm's *)
let add_forest forest rope len =
  let i = ref 0 in
  let sum = ref empty in
    while len > min_len.(!i+1) do
      if forest.(!i).c <> Empty then begin
        sum := concat_fast forest.(!i).c !sum;
        forest.(!i).c <- Empty
      end;
      incr i
    done;
    sum := concat_fast !sum rope;
    let sum_len = ref (length !sum) in
      while !sum_len >= min_len.(!i) do
        if forest.(!i).c <> Empty then begin
          sum := concat_fast forest.(!i).c !sum;
          sum_len := !sum_len + forest.(!i).len;
          forest.(!i).c <- Empty;
        end;
        incr i
      done;
      decr i;
      forest.(!i).c <- !sum;
      forest.(!i).len <- !sum_len

let concat_forest forest =
  Array.fold_left (fun s x -> concat_fast x.c s) Empty forest

let rec balance_insert rope len forest = match rope with
    Empty -> ()
  | Leaf _ -> add_forest forest rope len
  | Concat(l,cl,r,cr,h) when h >= max_height || len < min_len.(h) ->
      balance_insert l cl forest;
      balance_insert r cr forest
  | x -> add_forest forest x len (* function or balanced *)

let balance r =
  match r with
      Empty -> Empty
    | Leaf _ -> r
    | _ ->
        let forest = Array.init max_height (fun _ -> {c = Empty; len = 0}) in
          balance_insert r (length r) forest;
          concat_forest forest

let bal_if_needed l r =
  let r = make_concat l r in
    if height r < max_height then r else balance r

let concat_str l = function
    Empty | Concat(_,_,_,_,_) -> invalid_arg "concat_str"
  | Leaf rs as r ->
      let lenr = String.length rs in
        match l with
          | Empty -> r
          | Leaf ls ->
              let slen = lenr + String.length ls in
                if slen <= leaf_size then Leaf (str_append ls rs)
                else make_concat l r (* height = 1 *)
          | Concat(ll, cll, Leaf lrs, clr, h) ->
              let slen = clr + lenr in
                if clr + lenr <= leaf_size then
                  Concat(ll, cll, Leaf (str_append lrs rs), slen, h)
                else
                  bal_if_needed l r
          | _ -> bal_if_needed l r

let append_char c r = concat_str r (Leaf (String.make 1 c))

let concat l = function
    Empty -> l
  | Leaf _ as r -> concat_str l r
  | Concat(Leaf rls,rlc,rr,rc,h) as r ->
      (match l with
          Empty -> r
        | Concat(_,_,_,_,_) -> bal_if_needed l r
        | Leaf ls ->
            let slen = rlc + String.length ls in
              if slen <= leaf_size then
                Concat(Leaf(str_append ls rls), slen, rr, rc, h)
              else
                bal_if_needed l r)
  | r -> (match l with Empty -> r | _ -> bal_if_needed l r)

let prepend_char c r = concat (Leaf (String.make 1 c)) r

let rec get i = function
    Empty -> raise Out_of_bounds
  | Leaf s ->
      if i >= 0 && i < String.length s then String.unsafe_get s i
      else raise Out_of_bounds
  | Concat (l, cl, r, cr, _) ->
      if i < cl then get i l
      else get (i - cl) r

let of_string = function
    s when String.length s = 0 -> Empty
  | s ->
      let min (x:int) (y:int) = if x <= y then x else y in
      let rec loop r s len i =
        if i < len then (* len - i > 0, thus Leaf "" can't happen *)
          loop (concat r (Leaf (String.sub s i (min (len - i) leaf_size))))
            s len (i + leaf_size)
        else
          r
      in loop Empty s (String.length s) 0

let rec sub start len = function
    Empty -> if start <> 0 || len <> 0 then raise Out_of_bounds else Empty
  | Leaf s ->
      if len > 0 then (* Leaf "" cannot happen *)
        (try Leaf (String.sub s start len) with _ -> raise Out_of_bounds)
      else if len < 0 || start < 0 || start > String.length s then
        raise Out_of_bounds
      else Empty
  | Concat(l,cl,r,cr,_) ->
      if start < 0 || len < 0 || start + len > cl + cr then raise Out_of_bounds;
      let left =
        if start = 0 then
          if len >= cl then
            l
          else sub 0 len l
        else if start > cl then Empty
        else if start + len >= cl then
          sub start (cl - start) l
        else sub start len l in
      let right =
        if start <= cl then
          let upto = start + len in
            if upto = cl + cr then r
            else if upto < cl then Empty
            else sub 0 (upto - cl) r
        else sub (start - cl) len r
      in
        concat left right

let to_string r =
  let rec strings l = function
      Empty -> l
    | Leaf s -> s :: l
    | Concat(left,_,right,_,_) -> strings (strings l right) left
  in
    string_of_string_list (strings [] r)

let insert start rope r =
  concat (concat (sub 0 start r) rope) (sub start (length r - start) r)

let remove start len r =
  concat (sub 0 start r) (sub (start + len) (length r - start - len) r)

let () =
  let r name v = Callback.register ("Rope." ^ name) v in
    r "empty"     (fun () -> empty);
    r "of_string" of_string;
    r "sub"       (fun r n m -> sub n m r);
    r "concat"    concat;
    r "length"    length;
    r "get"       (fun r i -> get i r);
    r "to_string" to_string
