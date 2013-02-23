(* Copyright (C) 2013 Ben Lewis and David Donna *)
(* util.ml, part of TexterQuest *)
(* LGPLv3 *)

let (@@) f x = f x

let int_time () = truncate @@ Unix.time ()

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

let split = Str.split (Str.regexp "[ \t]+")

let no_debug = ref false

let debug s = if not !no_debug then print_endline (">> " ^ s)

let _ = Random.init (int_time ())

let (|?) x y = match x with
  | None -> y
  | Some x -> x

module List' = struct

  let rec take_some = function
    | [] -> []
    | None::xs -> take_some xs
    | (Some x)::xs -> x::(take_some xs)

  let remove_all item = List.filter (fun x -> x <> item)

  let rec remove_one item = function
    | [] -> []
    | x::xs -> if x = item then xs else x::(remove_one item xs)
    
end
