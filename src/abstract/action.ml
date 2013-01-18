(* Copyright (C) 2013 Ben Lewis and David Donna *)
(* action.ml, part of TexterQuest *)
(* LGPLv3 *)

include Util

(*

type t =
  | Either of Actor.t * any_action
  | Combat of Actor.t * int * combat_action
  | NonCombat of Actor.t * noncombat_action

*)

type t =
  | Move of int
  | Cast of string
  | ActionError

let action_of_string actor input = 
  match Str.bounded_split (Str.regexp "[., \t]+") input 2 with
    | ["go"; i] -> Move (int_of_string i)
    (* For spell:
     * extract target designation
     * get spell, translate to syllable list
    *)
    | _ -> ActionError

let string_of_action act = 
  match act with
  | Move i -> "move " ^ (string_of_int i)
  | Cast spell_and_target -> "cast " ^ spell_and_target
  | ActionError -> "No action done."

