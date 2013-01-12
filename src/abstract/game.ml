(* Copyright (C) 2013 Ben Lewis and David Donna *)
(* game.ml, part of TexterQuest *)
(* LGPLv3 *)

include Types

let players = Hashtbl.create 100

let get_character = Hashtbl.find players

let init_character = Util.generate
  (fun i player ->
    let initial_location = "start" in
    let name = "player_" ^ (string_of_int i) in
    Actor.create name initial_location)

let player_login player = Raw ("Hello, " ^ player ^ ". Make a character? ")

let player_select_character player character =
  let character = init_character player in
  Hashtbl.add players player character;
  let room = Actor.get_loc character in
  Room.enter character room  

let player_logout player =
  Room.leave (get_character player);
  Hashtbl.remove players player

let check actor action = true

let process_input player input =
  let open Action in
      let character = get_character player in
      let act = action_of_string character input in
      if check character act then
        match act with
          | Move i -> Room.move character i
          | ActionError -> Raw input
      else Raw "INVALID COMMAND"
