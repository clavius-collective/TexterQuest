(* Copyright (C) 2013 Ben Lewis and David Donna *)
(* game.ml, part of TexterQuest *)
(* LGPLv3 *)

include Util

(* module state *)
let players = Hashtbl.create hash_size
let lock = Mutex.create ()
let locked f x =
    Mutex.lock lock;
    let value = f x in
    Mutex.unlock lock;
    value

let new_character = locked (generate_str "character"
  (fun name send player -> Actor.create_new ~send name))

let get_character = locked (Hashtbl.find players)

let player_login player = Raw ("Hello, " ^ player ^ ". Make a character?")

let player_select_character = locked (fun send player character ->
  let character = new_character send player in
  Hashtbl.add players player character;
  let room = Actor.get_loc character in
  send (Room.enter character room))

let player_logout = locked (fun player ->
  Room.leave (get_character player);
  Hashtbl.remove players player)

(* 
 * instead of just responding, action will be sent to either combat or
 * mutator thread, depending on whether it is a combat action
 *)
let process_action action = 
  Mutator.submit action
        
let process_input = locked (fun player input ->
  let character = get_character player in
  let action = Action.action_of_string character input in
  process_action action)
