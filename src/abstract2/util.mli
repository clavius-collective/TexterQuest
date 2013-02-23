(* Copyright (C) 2013 Ben Lewis and David Donna *)
(* util.mli, part of TexterQuest *)
(* LGPLv3 *)

(** All-purpose utility functions. May eventually be converted into its own
    external library, and then imported.
    @author David Donna *)

(** Return a int representing the current time. *)
val int_time : unit -> int

(** Supply a counter that will be incremented each time f is called. *)
val generate : (int -> 'a -> 'b) -> 'a -> 'b

(** Given a string "foo", supply a stream of "foo_1", "foo_2", etc. *)
val generate_str : string -> (string -> 'a -> 'b) -> 'a -> 'b

(** Right-associative application function. C.f. Haskell's $ operator. *)
val (@@) : ('a -> 'b) -> 'a -> 'b
  
(** Like =, but case-insensitive. *)
val matches_ignore_case : string -> string -> bool

(** Statefully append an element to a list ref. *)
val (<<) : 'a list ref -> 'a -> unit

(** Split on any combination of spaces and tabs. *)
val split : string -> string list

(** Flag to turn debugging off (defaults to false). *)
val no_debug : bool ref

(** Debug function that gets turned off when {! no_debug} is true. *)
val debug : string -> unit

(** For x |? y, if x = Some x' then x' else y. *)
val (|?) : 'a option -> 'a -> 'a

(** Additional functionality for lists. *)
module List' : sig

  (** filter a list of options to just get the Some values *)
  val take_some : 'a option list -> 'a list

  (** return a copy of a list with all instances of the specified item
      removed *)
  val remove_all : 'a -> 'a list -> 'a list

  (** return a copy of a list with the first instance of the specified item
      removed *)
  val remove_one : 'a -> 'a list -> 'a list
  
end
