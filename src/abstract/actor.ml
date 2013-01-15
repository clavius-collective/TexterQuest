(* Copyright (C) 2013 Ben Lewis and David Donna *)
(* actor.ml, part of TexterQuest *)
(* LGPLv3 *)

include Util

let initial_location = "start"

type t = {
  name             : string;
  wounds           : Wound.t;
  traits           : Trait.vector;
  send             : fstring -> unit;
  mutable location : room_id;  
}

(* 
 * Eventually split into create with labelled arguments for a loaded character,
 * and create_new to take a minimal set of arguments and flesh out the record.
 *)
let create ~wounds ~traits ~send ~location name  =
  {
    name;
    location;
    wounds;
    traits;
    send;
  }

let create_new = create
  ~wounds:(Wound.create ())
  ~traits:(Trait.create_traits ())
  ~location:initial_location

let get_name t = t.name

let get_loc t = t.location

let set_loc t room_id = t.location <- room_id

let add_wound t = Wound.add_wound t.wounds

let defeated t =
  let minor, middling, mortifying = Wound.total_wounds t.wounds in
  let sum = List.fold_left
    (fun small large -> small / 3 + large)
    0
    [minor; middling; mortifying]
  in
  sum > 2

let send t = t.send

let describe t = Raw (t.name)
