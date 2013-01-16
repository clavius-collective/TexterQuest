(* Copyright (C) 2013 Ben Lewis and David Donna *)
(* actor.ml, part of TexterQuest *)
(* LGPLv3 *)

include Util

let initial_location = "start"

type actor = {
  name             : string;
  wounds           : Wound.t;
  traits           : Trait.vector;
  send             : fstring -> unit;
  mutable location : room_id;  
}

type t =
  | Combat of actor * Combat.t
  | Noncombat of actor

(* 
 * Eventually split into create with labelled arguments for a loaded character,
 * and create_new to take a minimal set of arguments and flesh out the record.
 *)
let create ~wounds ~traits ~send ~location name  =
  Noncombat {
    name;
    location;
    wounds;
    traits;
    send;
  }

let record = function
  | Combat (actor, _)
  | Noncombat actor -> actor

let create_new = create
  ~wounds:(Wound.create ())
  ~traits:(Trait.create_traits ())
  ~location:initial_location

let get_name t = (record t).name

let get_loc t = (record t).location

let set_loc t room_id = (record t).location <- room_id

let add_wound t = Wound.add_wound (record t).wounds

let get_wounds t = Wound.total_wounds (record t).wounds

let defeated t =
  let minor, middling, mortifying = get_wounds t in
  let sum = List.fold_left
    (fun small large -> small / 3 + large)
    0
    [minor; middling; mortifying]
  in
  sum > 2

let send t = (record t).send

let describe t = Raw (record t).name

let tempo_generator actor () = 0
let initial_balance actor = 0
let initial_focus actor = 0
let enter_combat = function
  | Combat (_, _) as actor -> actor
  | Noncombat actor ->
      let generator = tempo_generator actor in
      let balance = initial_balance actor in
      let focus = initial_focus actor in
      let stats = Combat.create ~generator ~balance ~focus in
      Combat (actor, stats)
