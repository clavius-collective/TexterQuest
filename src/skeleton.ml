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

include Util

let do_debug = ref false
let debug s = if !do_debug then print_endline (">> " ^ s)

type room_id = string

type fstring =
  | Raw of string
  | Bold of fstring
  | Italic of fstring
  | Underline of fstring
  | Color of int * fstring
  | Concat of fstring * fstring
  | Sections of fstring list
  | List of fstring list

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
  val enter : Actor.t -> room_id -> fstring
  val move : Actor.t -> int -> fstring
    
  val list_actors : room_id -> fstring
  val list_exits : room_id -> fstring
  val describe : room_id -> fstring
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
    
  let get_exit id i = fst (get id).exits.(i - 1)
    
  let list_actors id =
    let actors = (get id).actors in
    Raw (match actors with
      | [] -> "nobody is here"
      | [x] -> (Actor.get_name x) ^ " is here"
      | l -> (String.concat ", " (List.map Actor.get_name l)) ^ " are here")
          
  let list_exits id =
    Raw (
    "Exits are: " ^
      (String.concat ", "
         (Array.to_list
            (Array.mapi
               (fun i (_, s) -> "(" ^ (string_of_int (i + 1)) ^ ") " ^ s)
               (get id).exits))))

  let describe id =
    Concat
      (Raw ((get id).description ^ "\n"),
       List [list_actors id; list_exits id])

  let leave actor =
    let id = Actor.get_loc actor in
    let rm = get id in
    rm.actors <- List.filter (fun a -> a <> actor) rm.actors
      
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
end

module Action : sig
  type t =
      Nothing
    | Move of int

  val action_of_string : string -> t
end = struct
  type t = 
      Nothing
    | Move of int

  let action_of_string s =
    let whitespace = Str.regexp "[ \t]+" in
    match Str.split whitespace s with
      | "move"::i::_ -> Move (int_of_string i)
      | _ -> Nothing
end

module Game : sig
  type player = string
  val process_input : player -> string -> fstring
  val player_login : player -> fstring
  val player_logout : player -> unit
end = struct
  type player = string

  let players = Hashtbl.create 100

  let get_character = Hashtbl.find players

  let init_character = Util.generate
    (fun i player ->
      let initial_location = "start" in
      let name = "player_" ^ (string_of_int i) in
      Actor.create name initial_location)

  let player_login p =
    let character = init_character () p in
    Hashtbl.add players p character;
    let room = Actor.get_loc character in
    Room.enter character room

  let player_logout p =
    Room.leave (get_character p);
    Hashtbl.remove players p

  let check actor action = true

  let process_input p s =
    let open Action in
    let act = action_of_string s in
    if check (get_character p) act then
      match act with
        | Nothing -> Raw s
        | Move i -> Room.move (get_character p) i
    else Raw "INVALID COMMAND"
end

module Telnet = struct
  open Unix

  type user = file_descr

  let users = Hashtbl.create 100
  let new_user = Util.generate (fun i -> "user_" ^ (string_of_int i))

  let send_output sock s =
    let rec send_part = function
      | Raw s -> 
          ignore (send sock s 0 (String.length s) [])
      | Bold s | Italic s | Underline s | Color (_, s) ->
          send_part s
      | Sections fstrings ->
          List.iter
            (fun s -> send_part (Concat (s, Raw "\n\n")))
            fstrings
      | List fstrings ->
          List.iter
            (fun s ->
              send_part (Concat (Raw "* ", Concat (s, Raw "\n"))))
            fstrings
      | Concat (s1, s2) ->
          send_part s1;
          send_part s2
    in
    send_part s; send_part (Raw "\n")

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
      List.iter (send_output sock) [
        Raw "TEXTER QUEST\n";
        Game.player_login player
      ]
    in

    let remove_client sock =
      clients := List.filter (fun s -> s <> sock) !clients
    in

    let handle sock =
      let max_len = 1024 in
      if sock = server then
        accept_client ()
      else
        let buffer = String.create max_len in
        let len = recv sock buffer 0 max_len [] in
        match len with
          | 0 -> 
              debug ((Hashtbl.find users sock) ^ "disconnected");
              remove_client sock
          | _ ->
              let input = String.sub buffer 0 len in
              let endline = Str.regexp "\r?\n\r?" in
              List.iter (process_input sock) (Str.split endline input)
    in

    while true do
      let input, _, _ = select (server::!clients) [] [] (-1.0) in
      List.iter handle input
    done
end

let _ =
  Arg.parse
    [
      "-v", Arg.Set do_debug, "verbose mode"
    ] (fun _ -> ()) "basic MUD";

  Telnet.start ()
