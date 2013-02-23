include Util
include Core
include Sexplib
include Sexplib.Std

type t' = I of int | F of float with sexp

type b = {
  name: string;
  num: t';
} with sexp
    
type transform' =
  | Rename of string
  | Reval of t'
with sexp

include Mask.Make (struct
  type t = b with sexp
  type transform = transform' with sexp
  let apply_transform t = function
    | Rename s -> { t with name = s }
    | Reval t' -> { t with num = t' }
end)

let t'_to_s = function
  | I x -> string_of_int x
  | F x -> string_of_float x

let to_s x = Sexplib.Sexp.to_string (sexp_of_t x)

let _ =
  let x = create {
    name = "foo";
    num = I 10;
  } in
  print_endline (to_s x);
  add_mask
    ~description:(Raw "yo")
    ~transform:(Rename "bar")
    ~decay:(expires_after 0)
    x;
  print_endline (to_s x);
  Thread.delay 0.2;
  print_endline (Sexplib.Sexp.to_string (sexp_of_b (get_value x)));
  print_endline (to_s x)
