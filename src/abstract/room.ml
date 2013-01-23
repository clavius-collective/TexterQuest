(* Copyright (C) 2013 Ben Lewis and David Donna *)
(* room.ml, part of TexterQuest *)
(* LGPLv3 *)

include Util

type room = {
  id : room_id;
  mutable actors : Actor.t list;
  description : string;
  exits : (room_id * string) array;
}

type t = room_id

(* module state *)
let rooms = Hashtbl.create hash_size

let get id = 
  try
    Hashtbl.find rooms id
  with
    | Not_found -> 
        (* let fields = db_lookup id in *)
        (* let room = room_of_db fields in *)
        (* Hashtbl.add rooms id room *)
        (* room *)
        failwith "implement the damn database already"

let create id description exits =
  let room = {
    id;
    actors = [];
    description;
    exits;
  } in
  Hashtbl.add rooms id room

let get_exit id i = fst (get id).exits.(i - 1)

let get_description id = Raw (get id).description

let list_actors id =
  let actors = (get id).actors in
  Raw (match actors with
    | [] -> "nobody is here"
    | [x] -> (Actor.get_name x) ^ " is here"
    | l -> (String.concat ", " (List.map Actor.get_name l)) ^ " are here")

let list_exits id =
  Raw ("Exits are: " ^
          (String.concat ", "
             (Array.to_list
                (Array.mapi
                   (fun i (_, s) -> "(" ^ (string_of_int (i + 1)) ^ ") " ^ s)
                   (get id).exits))))
    
let describe id =
  Sections [
    get_description id;
    list_actors id;
    list_exits id;
  ]

let leave actor =
  let id = Actor.get_loc actor in
  let rm = get id in
  rm.actors <- List.filter (fun a -> a != actor) rm.actors

let enter actor id =
  let rm = get id in
  Actor.set_loc actor id;
  rm.actors <- actor::rm.actors;
  describe id

let move actor i =
  let from = Actor.get_loc actor in
  let into = get_exit from i in
  leave actor;
  enter actor into
