(* Copyright (C) 2013 Ben Lewis and David Donna *)
(* Licensed under LGPLv3 *)

(*
  This file is toy code. Currently, the mutual dependence of the Actor and Room
  modules is resolved by using recursive modules. However, this will likely
  become infeasible as more interdependent modules are created. So, it is
  recommended that we create a types.ml at the top of the project, or weaken
  type safety by using globally defined types (e.g. string instead of Room.t).

  This code can be used to make a minimal MUD, once a server and interaction
  loop are created. I'll probably get to that tomorrow (jan 3).
*)


type room_id = string

module Actor : sig
  type t
    
  val create : string -> string -> t
  val get_name : t -> string
  val get_loc : t -> room_id
  val set_loc : t -> room_id -> unit
end = struct
  type t = {
    name : string;
    mutable location : room_id;
  }
      
  let create name location = {
    name;
    location;
  }
  
  let get_name a = a.name
  let get_loc a = a.location
  let set_loc a r = a.location <- r
end
  
module Room : sig
  val create : room_id -> string -> (room_id * string) array -> unit
    
  val leave : Actor.t -> room_id -> unit
  val enter : Actor.t -> room_id -> unit
  val move : Actor.t -> int -> unit
    
  val list_actors : room_id -> string
  val list_exits : room_id -> string
  val describe : room_id -> string
end = struct
  type room = {
    id : room_id;
    mutable actors : Actor.t list;
    description : string;
    exits : (room_id * string) array;
  }
      
  let rooms = Hashtbl.create 100

  let get = Hashtbl.find rooms
      
  let create id description exits =
    let room = {
      id;
      actors = [];
      description;
      exits;
    } in
    Hashtbl.add rooms id room
    
  let leave actor id =
    let rm = get id in
    rm.actors <- List.filter (fun a -> a <> actor) rm.actors
      
  let enter actor id = 
    let rm = get id in
    Actor.set_loc actor id;
    rm.actors <- actor::rm.actors
      
  let get_exit id i = fst (get id).exits.(i)
    
  let move actor i =
    let from = Actor.get_loc actor in
    leave actor from;
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

(* let module type SERVER : sig  *)

(* end *)

module Reactor = (* functor (Server : SERVER) ->  *)struct
  open Unix

  let process_input input sock =
    ignore (send sock input 0 (String.length input) [])

  let start () =

    let clients = ref [] in
    let pcs = Hashtbl.create 100 in

    let get_character client_sock client_addr = 
      let char = Actor.create client_addr "start" in
      Hashtbl.remove pcs client_sock;
      Hashtbl.add pcs client_sock char;
      char
    in

    Room.create "start" "the starting zone" [|"other", "another room"|];
    Room.create "other" "the other room" [|"start", "the first room"|];

    let server =
      let server_sock = socket PF_INET SOCK_STREAM 0 in
      setsockopt server_sock SO_REUSEADDR true;
      let address = (gethostbyname(gethostname ())).h_addr_list.(0) in
      bind server_sock (ADDR_INET (address, 1029));
      listen server_sock 10;
      server_sock
    in
    
    let new_name =
      let number = ref 0 in
      fun () ->
        incr number;
        "player_" ^ (string_of_int !number)
    in

    let accept_client () =
      let (sock, addr) = accept server in
      clients := sock :: !clients;
      let char = get_character sock (new_name ()) in
      Room.enter char "start";
      
      let str = "Hello\n" in
      let len = String.length str in
      ignore (send sock str 0 len [])
    in

    let read sock =
      let max_len = 1024 in
      if sock = server then
        accept_client ()
      else
        let buffer = String.create max_len in
        let len = recv sock buffer 0 max_len [] in
        let input = String.sub buffer 0 len in
        process_input input sock
    in

    while true do
      let input, _, _ = select (server::!clients) [] [] (-1.0) in
      List.iter read input
    done

end

let _ = Reactor.start ()
