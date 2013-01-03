(*
This file is toy code. Currently, the mutual dependence of the Actor and Room
modules is resolved by using recursive modules. However, this will likely
become infeasible as more interdependent modules are created. So, it is
recommended that we create a types.ml at the top of the project, or weaken
type safety by using globally defined types (e.g. string instead of Room.t).

This code can be used to 
*)

type room_id = string

module Actor : sig
  type t
  val get_name : t -> string
  val get_loc : t -> room_id
  val set_loc : t -> room_id -> unit
end = struct
  type t = {
    name : string;
    mutable location : room_id;
  }
    
  let get_name a = a.name
  let get_loc a = a.location
  let set_loc a r = a.location <- r
end

module Room : sig
  val exit : Actor.t -> room_id -> unit
  val enter : Actor.t -> room_id -> unit
  val move : Actor.t -> int -> unit

  val list_actors : room_id -> string
  val list_exits : room_id -> string
  val describe : room_id -> string
end = struct
  type room = {
      mutable actors : Actor.t list;
      description : string;
      exits : (room_id * string) array;
  }
  
  let get = 
    let rooms = Hashtbl.create 100 in
    Hashtbl.find rooms

  let create description exits = {
    actors = [];
    description;
    exits;
  }

  let exit actor id =
    let rm = get id in
    rm.actors <- List.filter (fun a -> a <> actor) rm.actors

  let enter actor id = 
    let rm = get id in
    Actor.set_loc actor id;
    rm.actors <- actor::rm.actors

  let get_exit id i = fst (get id).exits.(i)

  let move actor i =
    let from = Actor.get_loc actor in
    exit actor from;
    enter actor (get_exit from i)

  let list_actors id =
    let actors = (get id).actors in
    match actors with
        [] -> "Nobody is here."
      | [x] -> (Actor.get_name x) ^ " is here."
      | l -> (String.concat ", " (List.map Actor.get_name l)) ^ " are here."

  let list_exits id =
    "Exits are:\n" ^
    (String.concat "\n"
      (Array.to_list
        (Array.mapi
          (fun i (_, s) -> "\n(" ^ (string_of_int i) ^ ") " ^ s)
          (get id).exits)))

  let describe id =
    (get id).description ^ "\n\n" ^
    (list_actors id) ^ "\n\n" ^
    (list_exits id)
end
