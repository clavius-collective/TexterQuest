(* Copyright (C) 2013 Ben Lewis and David Donna *)
(* game.ml, part of TexterQuest *)
(* LGPLv3 *)

include Util

(* this will eventually be the listener module, with a listener thread *)

let game_lock = Mutex.create ()

let locked f x =
  Mutex.lock game_lock;
  let value = f x in
  Mutex.unlock game_lock;
  value

let players = Hashtbl.create 100

let new_character = generate_str "character"
  (fun name send player -> Actor.create_new ~send name)

let get_character = Hashtbl.find players

let player_login player = Raw ("Hello, " ^ player ^ ". Make a character?")

let player_select_character send player character =
  let character = new_character send player in
  Hashtbl.add players player character;
  let room = Actor.get_loc character in
  send (Room.enter character room)

let player_logout player =
  Room.leave (get_character player);
  Hashtbl.remove players player

let check actor action = true

let process_input = locked (fun player input ->
  let open Action in
      let character = get_character player in
      let act = action_of_string character input in
      (* checking will be moved into mutator module *)
      if check character act then
        (Actor.send character) (match act with
          | Move i -> Room.move character i
          | Cast spell -> Raw input
          | ActionError -> Raw input)
      else (Actor.send character) (Raw "INVALID COMMAND"))
