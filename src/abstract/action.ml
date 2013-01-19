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

type action =
  | Move of int
  | Cast of string
  | ActionError

type t = Actor.t * action

let action_of_string actor input =
  actor,
  match Str.bounded_split (Str.regexp "[., \t]+") input 2 with
    | ["go"; i] -> Move (int_of_string i)
    | _ -> ActionError

let string_of_action act = 
  match act with
  | actor, (Move i) -> "move " ^ (string_of_int i)
  | actor, (Cast spell_and_target) -> "cast " ^ spell_and_target
  | actor, ActionError -> "No action done."

let get_actor (actor, _) = actor
let get_cost t = 0
