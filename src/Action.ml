(* Copyright (C) 2013 Ben Lewis and David Donna *)
(* Action.ml, part of TexterQuest *)
(* LGPLv3 *)

type t = Move of Actor.t * Room.t
         | Action_Error

let action_of_string input calling_actor = 
  let divided_input = Str.split (regexp "[., \t]+") input in
  (* Now the input is in a list format; we can feel free to match the first
     element against more complex situations. *)
  match divided_input.(0) with
  | "Go" -> Move (calling_actor, Room.room_of_string (divided_input.(1)))
  | "go" -> Move (calling_actor, Room.room_of_string (divided_input.(1)))
  | _ -> Action_Error
 end

let string_of_action act = 
  match act with
  | Move(a,r) -> (Actor.string_of_actor a) ^ " goes to " ^ (Room.string_of_room
  r) ^ "."
  | Action_Error -> "No action done."
 end
  
(* There will need to be lists of synonyms for actions; this part will get
  quite complex. *)
  
