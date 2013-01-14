(* Copyright (C) 2013 Ben Lewis and David Donna *)
(* object.mli, part of TexterQuest *)
(* LGPLv3 *)

open Types

type t =
  | OActor of Actor.t
  | ORoom of room_id
  | OItem of Item.t

val describe : t -> fstring
