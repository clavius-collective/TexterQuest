(* Copyright (C) 2013 Ben Lewis and David Donna *)
(* types.mli, part of TexterQuest *)
(* LGPLv3 *)

(* return a int representing the current time *)
val get_time : unit -> int

(* supply a counter that will be incremented each time f is called *)
val generate : (int -> 'a -> 'b) -> 'a -> 'b

(* given a string "foo", supply a stream of "foo_1", "foo_2", etc. *)
val generate_str : string -> (string -> 'a -> 'b) -> 'a -> 'b

(* right-associative application function (like Haskell's $ operator) *)
val (@@) : ('a -> 'b) -> 'a -> 'b
  
(* return a copy of a list with the specified item removed *)
val list_remove : 'a -> 'a list -> 'a list
  
(* like = but cooler *)
val matches_ignore_case : string -> string -> bool

(* list ref stateful append *)
val (<<) : 'a list ref -> 'a -> unit

(* whitespace split *)
val split : string -> string list

(* debugging stuff *)
val no_debug : bool ref

(* debug function that gets turned off by -q flag *)
val debug : string -> unit

(* the size of the hash tables storing information *)
val hash_size : int

(* filter a list of options to just get the real ones *)
val take_some : 'a option list -> 'a list

val (|?) : 'a option -> 'a -> 'a
