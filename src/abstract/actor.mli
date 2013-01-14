(* Copyright (C) 2013 Ben Lewis and David Donna *)
(* actor.mli, part of TexterQuest *)
(* LGPLv3 *)

open Types

type t
    
val create :
  wounds:Wound.t         ->
  traits:Trait.vector    ->
  send:(fstring -> unit) ->                    (* send *)
  location:room_id       ->                    (* location *)
  string                 ->                    (* name *)
  t

val create_new : send:(fstring -> unit) -> string -> t

val send : t -> fstring -> unit

(* simple accessors *)
val get_name : t -> string
val get_loc : t -> room_id

val set_loc : t -> room_id -> unit
val add_wound : t -> ?duration:int -> Wound.severity -> unit

val defeated : t -> bool
