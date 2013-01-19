(* Copyright (C) 2013 Ben Lewis and David Donna *)
(* game.ml, part of TexterQuest *)
(* LGPLv3 *)

include Util

(* this will eventually be the listener module, with a listener thread *)

(* module state *)
let players = Hashtbl.create 100
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

let process_input = locked (fun player input ->
  let open Action in
      let character = get_character player in
      let act = action_of_string character input in
      (* 
         instead of just responding, action will be sent to either combat or
         mutator thread, depending on whether it is a combat action
      *)
      (Actor.send character) (match act with
        | Move i -> Room.move character i
        | Cast spell -> Raw input
        | ActionError -> Raw "INVALID COMMAND"))
