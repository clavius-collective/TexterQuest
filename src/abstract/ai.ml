(* Copyright (C) 2013 Ben Lewis and David Donna *)
(* game.ml, part of TexterQuest *)
(* LGPLv3 *)

include Util

let default params = true

type parameters = {
  ai_actor : Actor.t;
  room : room_id;
  opponent : Actor.t list;
}

type behavior =
  | Act of (parameters -> Action.t)
  | Conditional of ((parameters -> bool) * behavior) list
  | Stochastic of (float * behavior) list

let make_params ~ai_actor ~room ~opponent =
  {
    ai_actor;
    room;
    opponent;
  }

let select_randomly options =
  let roll = Random.float 1.0 in
  let rec maybe_choose current = function
      | [] ->
          Act (fun params -> params.ai_actor, Action.ActionError)
      | (range, behavior)::xs ->
          if range >= current then
            behavior
          else
            maybe_choose (current -. range) xs
  in
  maybe_choose roll options

let rec choose_action parameters = function
  | Act create_action ->
      create_action parameters
  | Conditional choices ->
      (match choices with
        | [] -> parameters.ai_actor, Action.ActionError
        | (cond, behavior)::xs ->
            if cond parameters then
              choose_action parameters behavior
            else
              choose_action parameters (Conditional xs))
  | Stochastic choices ->
      choose_action parameters (select_randomly choices)
