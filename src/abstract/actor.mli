(* Copyright (C) 2013 Ben Lewis and David Donna *)
(* actor.mli, part of TexterQuest *)
(* LGPLv3 *)

open Util

(*
 * NOTA BENE: because Actor.t has a function field (send), the = and <>
 * operators will throw an exception. Use == and != instead; they should be
 * equivalent for our intents and purposes.
 *)
type t

val create :
  wounds   : Wound.t           ->
  traits   : Trait.vector      ->
  send     : (fstring -> unit) ->       (* send *)
  location : room_id           ->       (* location *)
  string                       ->       (* name *)
  t

val create_new : send:(fstring -> unit) -> string -> t

val send : t -> fstring -> unit

(* simple accessors *)
val get_name : t -> string

val get_loc : t -> room_id

val set_loc : t -> room_id -> unit

val add_wound : t -> ?duration:int -> ?discount:int -> Wound.severity -> unit

val is_defeated : t -> bool

val describe : t -> fstring

val get_focus : t -> int

val get_balance : t -> int

val enter_combat : t -> unit

val leave_combat : t -> unit
