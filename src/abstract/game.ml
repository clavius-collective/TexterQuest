include Types

type player = string

let players = Hashtbl.create 100

let get_character = Hashtbl.find players

let init_character = Util.generate
  (fun i player ->
    let initial_location = "start" in
    let name = "player_" ^ (string_of_int i) in
    Actor.create name initial_location)

let player_login p =
  let character = init_character p in
  Hashtbl.add players p character;
  let room = Actor.get_loc character in
  Room.enter character room

let player_logout p =
  Room.leave (get_character p);
  Hashtbl.remove players p

let check actor action = true

let process_input p s =
  let open Action in
      let act = action_of_string (get_character p) s in
      if check (get_character p) act then
        match act with
          | Move i -> Room.move (get_character p) i
          | ActionError -> Raw s
      else Raw "INVALID COMMAND"
