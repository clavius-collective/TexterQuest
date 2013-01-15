(* Copyright (C) 2013 Ben Lewis and David Donna *)
(* object.ml, part of TexterQuest *)
(* LGPLv3 *)

include Util

type t =
  | OActor of Actor.t
  | ORoom of room_id
  | OItem of Item.t

let describe = function
  | OActor x -> Actor.describe x
  | ORoom x -> Room.describe x
  | OItem x -> Item.describe x
