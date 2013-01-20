(* Copyright (C) 2013 Ben Lewis and David Donna *)
(* game.ml, part of TexterQuest *)
(* LGPLv3 *)

include Util

let default params = true

type parameters = {
  ai_actor : Actor.t;
  room : room_id;
  opponent : Actor.t list option;
}

type behavior =
  | Act of (parameters -> Action.t)
  | Conditional of ((parameters -> bool) * behavior) list
  | Stochastic of (float * behavior) list

type aggro =
  | Appear
  | Target
  | Harm
      
type t = {
  aggro : aggro;
  behavior : behavior;
}

let select_randomly options =
  let roll = Random.float 1.0 in
  let rec maybe_choose current = function
    | [] ->
        Act (fun params -> Action.error params.ai_actor)
    | (range, behavior)::xs ->
        if range >= current then
          behavior
        else
          maybe_choose (current -. range) xs
  in
  maybe_choose roll options

let choose_action  ~ai_actor ~room ~opponent t =
  let parameters = {
    ai_actor;
    room;
    opponent;
  } in
  let rec choose_action' = function
    | Act create_action ->
        create_action parameters
    | Conditional choices ->
        (match choices with
          | [] -> Action.error parameters.ai_actor
          | (cond, behavior)::xs ->
              if cond parameters then
                choose_action' behavior
              else
                choose_action' (Conditional xs))
    | Stochastic choices ->
        choose_action' (select_randomly choices)
  in
  choose_action' t.behavior

let when_aggro t = t.aggro
