(* Copyright (C) 2013 Ben Lewis and David Donna *)
(* object.mli, part of TexterQuest *)
(* LGPLv3 *)

open Util

type t =
  | ActorObj of Actor.t
  | RoomObj of Room.t
  | ItemObj of Item.t

val describe : t -> fstring
