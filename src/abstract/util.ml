let get_time () = truncate (Unix.time ())

let generate f =
  let _counter = ref 0 in
  fun x ->
    incr _counter;
    f !_counter x

let generate_str s =
  generate (fun i () -> s ^ "_" ^ (string_of_int i))

let (@@) f x = f x

let matches_ignore_case pattern string =
  let open Str in
      let re = regexp_case_fold pattern in
      string_match re string 0

let remove item = List.filter (fun x -> x <> item)

let (<=) list_ref elt = list_ref := elt :: !list_ref

let split = Str.split (Str.regexp "[ \t]+")
