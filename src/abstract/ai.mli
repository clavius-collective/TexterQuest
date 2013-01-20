(* Copyright (C) 2013 Ben Lewis and David Donna *)
(* game.ml, part of TexterQuest *)
(* LGPLv3 *)

open Util

type t

type aggro =
  | Appear
  | Target
  | Harm

val choose_action : 
  ai_actor : Actor.t ->
  room : room_id ->
  opponent : Actor.t list option ->
  t ->
  Action.t

val when_aggro : t -> aggro
