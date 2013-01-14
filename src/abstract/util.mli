(* return an int representing the current time *)
val get_time : unit -> int

(* supply a counter that will be incremented each time f is called *)
val generate : (int -> 'a -> 'b) -> 'a -> 'b

(* given a string "foo", supply a stream of "foo_1", "foo_2", etc. *)
val generate_str : string -> unit -> string

(* right-associative application function (like Haskell's $ operator) *)
val (@@) : ('a -> 'b) -> 'a -> 'b
  
(* return a copy of a list with the specified item removed *)
val remove : 'a -> 'a list -> 'a list
  
(* like = but cooler *)
val matches_ignore_case : string -> string -> bool

(* list ref append *)
val (<=) : 'a list ref -> 'a -> unit

(* whitespace split *)
val split : string -> string list
