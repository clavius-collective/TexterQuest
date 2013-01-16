(* Copyright (C) 2013 Ben Lewis and David Donna *)
(* types.ml, part of TexterQuest *)
(* LGPLv3 *)

type 'a mask = ('a -> 'a) * int

(* fundamental data types *)
type room_id = string

type username = string

type user_state =
  | Connected
  | CharSelect of username
  | LoggedIn   of username

(* formatted output *)
type color = int

type fstring =
  | Raw        of string
  | Bold       of fstring
  | Italic     of fstring
  | Underline  of fstring
  | Color      of color * fstring
  | Sections   of fstring list
  | Concat     of fstring list

let get_time () = truncate (Unix.time ())

let generate f =
  let _counter = ref 0 in
  fun x ->
    incr _counter;
    f !_counter x

let generate_str s = generate (fun i () -> s ^ "_" ^ (string_of_int i))

let (@@) f x = f x

let (>>) elt list_ref = list_ref := elt :: !list_ref

let matches_ignore_case pattern string =
  let re = Str.regexp_case_fold pattern in
  Str.string_match re string 0

let remove item = List.filter (fun x -> x <> item)

let split = Str.split (Str.regexp "[ \t]+")

let no_debug = ref false

let debug s = if not !no_debug then print_endline (">> " ^ s)

let _ = Random.init (get_time ())
