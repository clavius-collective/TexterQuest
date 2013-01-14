(* Copyright (C) 2013 Ben Lewis and David Donna *)
(* actor.ml, part of TexterQuest *)
(* LGPLv3 *)

include Types

type t = {
  name : string;
  mutable location : room_id;
  wounds : Wound.t
}

let create ?wounds name location =
  let wounds = match wounds with
    | Some w -> w
    | None -> Wound.create ()
  in
  {
    name;
    location;
    wounds;
  }

let get_name actor = actor.name
let get_loc actor = actor.location
let set_loc actor room_id = actor.location <- room_id
let add_wound t = Wound.add_wound t.wounds
