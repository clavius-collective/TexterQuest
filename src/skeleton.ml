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
let id s = s
type formatted_string =
    Newline
  | Format of string
  | Concat of formatted_string * formatted_string
let format s = Format s

module Actor : sig
  type t
    
  val create : string -> room_id -> t
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

  val leave : Actor.t -> unit
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
    
  let leave actor =
    let id = Actor.get_loc actor in
    let rm = get id in
    rm.actors <- List.filter (fun a -> a <> actor) rm.actors
      
  let enter actor id = 
    let rm = get id in
    Actor.set_loc actor id;
    rm.actors <- actor::rm.actors
      
  let get_exit id i = fst (get id).exits.(i)
    
  let move actor i =
    let from = Actor.get_loc actor in
    leave actor;
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

module Game : sig
  type player = string
  val process_input : player -> string -> formatted_string
  val player_login : player -> formatted_string
  val player_logout : player -> unit
end = struct
  type player = string

  let players = Hashtbl.create 100

  let get_character = Hashtbl.find players

  let init_character = 
    let initial_location = id "start" in
    let count = ref 0 in
    fun player ->
      incr count;
      let name = "player_" ^ (string_of_int !count) in
      Actor.create name initial_location

  let player_login p =
    let character = init_character p in
    Hashtbl.add players p character;
    let room = Actor.get_loc character in
    Room.enter character room;
    format (Room.describe room)

  let player_logout p =
    Room.leave (get_character p);
    Hashtbl.remove players p

  let process_input p s = format s
end

module Telnet = struct
  open Unix

  let users = Hashtbl.create 100
  let new_user =
    let count = ref 0 in
    fun () ->
      incr count;
      "user_" ^ (string_of_int !count)

  let send_raw sock s = ignore (send sock s 0 (String.length s) [])

  let rec send_output sock = function
      Format s -> 
        let output = s ^ "\n" in
        send_raw sock output
    | Newline ->
        send_raw sock "\n"
    | Concat (s1, s2) ->
        send_output sock s1;
        send_output sock s2

  let process_input sock input =
    let output = Game.process_input (Hashtbl.find users sock) input in
    send_output sock output

  let start () =
    let clients = ref [] in

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
    
    let accept_client () =
      let (sock, addr) = accept server in
      clients := sock :: !clients;
      let player = new_user () in
      Hashtbl.add users sock player;
      send_output sock (Game.player_login player)
    in

    let handle sock =
      let max_len = 1024 in
      if sock = server then
        accept_client ()
      else
        let buffer = String.create max_len in
        let len = recv sock buffer 0 max_len [] in
        let input = String.sub buffer 0 len in
        let endline = Str.regexp "\r?\n\r?" in
        List.iter (process_input sock) (Str.split endline input)
    in

    while true do
      let input, _, _ = select (server::!clients) [] [] (-1.0) in
      List.iter handle input
    done

end

let _ = Telnet.start ()
