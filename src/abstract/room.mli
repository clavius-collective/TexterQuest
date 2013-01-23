(* Copyright (C) 2013 Ben Lewis and David Donna *)
(* room.mli, part of TexterQuest *)
(* LGPLv3 *)

(*
 * NOTA BENE: THIS SHIT IS STATEFUL
 *)

open Util 

type t = room_id

(*
 * This function does not return a room; it ADDS A ROOM to the module's
 * internal graph of the game map.
 *)
val create :
  room_id                  ->           (* identifier                        *)
  string                   ->           (* description                       *)
  (room_id * string) array ->           (* exits                             *)
  unit

val leave : Actor.t -> unit
val enter : Actor.t -> t -> fstring
val move : Actor.t -> int -> fstring
   
val list_actors : t -> fstring
val list_exits : t -> fstring
val describe : t -> fstring
