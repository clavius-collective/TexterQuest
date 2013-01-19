(* Copyright (C) 2013 Ben Lewis and David Donna *)
(* object.ml, part of TexterQuest *)
(* LGPLv3 *)

include Util

type t =
  | ActorObj of Actor.t
  | RoomObj of Room.t
  | ItemObj of Item.t

let describe = function
  | ActorObj x -> Actor.describe x
  | RoomObj x -> Room.describe x
  | ItemObj x -> Item.describe x
