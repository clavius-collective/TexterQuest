(* Copyright (C) 2013 Ben Lewis and David Donna *)
(* action.ml, part of TexterQuest *)
(* LGPLv3 *)

include Util

type action =
  | Move of int
  | Cast of string
  | ActionError

type context =
  | Combat
  | Noncombat
  | Either

type t = {
  actor : Actor.t;
  action : action;
  cost : int option;
}

(*
 * Some question remains as to how targeting will be represented. Possibly:
 *   * required list field (can be empty list)
 *   * list option (not really recommended)
 *   * folded in as a part of actions that must be targeted
 *       * as an option, if there are actions which may or may not be targeted
 *)

let error actor = {
  actor;
  action = ActionError;
  cost = None;
}

let action_of_string actor input =
  let delimiter = Str.regexp "[., \t]+" in
  let tokens = Str.bounded_split delimiter input 2 in
  let action, cost = match tokens with
    | ["go"; i] -> Move (int_of_string i), None
    | _ -> ActionError, None
  in
  {
    actor;
    action;
    cost;
  }

let string_of_action t = 
  match t.action with
    | Move i -> "move " ^ (string_of_int i)
    | Cast spell_and_target -> "cast " ^ spell_and_target
    | ActionError -> "No action done."
        
let get_cost t = t.cost

let get_actor t = t.actor
  
let get_context t = match t.action with
  | Move _ -> Noncombat
  | Cast _ -> Combat
  | ActionError -> Either

let combat_compatible t = match get_context t with
  | Combat
  | Either -> true
  | Noncombat -> false

let noncombat_compatible t = match get_context t with
  | Noncombat
  | Either -> true
  | Combat -> false

let get_action t = t.action
