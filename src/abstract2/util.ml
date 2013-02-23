(* Copyright (C) 2013 Ben Lewis and David Donna *)
(* types.ml, part of TexterQuest *)
(* LGPLv3 *)

let (@@) f x = f x

let get_time () = truncate @@ Unix.time ()

let generate f =
  let _counter = ref 0 in
  fun x ->
    incr _counter;
    f !_counter x

let generate_str s f = generate (fun i -> f (s ^ "_" ^ (string_of_int i)))

let (<<) list_ref elt = list_ref := elt :: !list_ref

let matches_ignore_case pattern string =
  let re = Str.regexp_case_fold pattern in
  Str.string_match re string 0

let list_remove item = List.filter (fun x -> x <> item)

let split = Str.split (Str.regexp "[ \t]+")

let no_debug = ref false

let debug s = if not !no_debug then print_endline (">> " ^ s)

let hash_size = 100

let rec take_some = function
  | [] -> []
  | None::xs -> take_some xs
  | (Some x)::xs -> x::(take_some xs)

let _ = Random.init (get_time ())

let (|?) x y = match x with
  | None -> y
  | Some x -> x
