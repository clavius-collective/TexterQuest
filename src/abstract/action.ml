(* Copyright (C) 2013 Ben Lewis and David Donna *)
(* Action.ml, part of TexterQuest *)
(* LGPLv3 *)

include Types

type t =
  | Move of int
  | ActionError

let action_of_string actor input = 
  match Str.split (Str.regexp "[., \t]+") input with
    | "move"::i::_
    | "go"::i::_ -> Move (int_of_string i)
    | _ -> ActionError

let string_of_action act = 
  match act with
  | Move i -> "move " ^ (string_of_int i)
  | ActionError -> "No action done."
  
(* There will need to be lists of synonyms for actions; this part will get
  quite complex. *)
