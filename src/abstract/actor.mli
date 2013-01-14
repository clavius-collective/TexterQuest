(* Copyright (C) 2013 Ben Lewis and David Donna *)
(* actor.mli, part of TexterQuest *)
(* LGPLv3 *)

open Types

type t
    
val create :
  string ->                             (* name *)
  room_id ->                            (* location *)
  t

(* simple accessors *)
val get_name : t -> string
val get_loc : t -> room_id

(* simple mutators *)
val set_loc : t -> room_id -> unit

val add_wound : t -> ?duration : int -> Wound.severity -> unit
