(* Copyright (C) 2013 Ben Lewis and David Donna *)
(* game.ml, part of TexterQuest *)
(* LGPLv3 *)

include Util

let players = Hashtbl.create 100

let get_character = Hashtbl.find players

let init_character send = generate
  (fun i player ->
    let name = "player_" ^ (string_of_int i) in
    Actor.create_new ~send name)

let player_login player = Raw ("Hello, " ^ player ^ ". Make a character?")

let player_select_character send player character =
  let character = init_character send player in
  Hashtbl.add players player character;
  let room = Actor.get_loc character in
  send (Room.enter character room)

let player_logout player =
  Room.leave (get_character player);
  Hashtbl.remove players player

let check actor action = true

let process_input player input =
  let open Action in
      let character = get_character player in
      let act = action_of_string character input in
      if check character act then
        (Actor.send character) (match act with
          | Move i -> Room.move character i
          | Cast spell -> Raw input
          | ActionError -> Raw input)
      else (Actor.send character) (Raw "INVALID COMMAND")
