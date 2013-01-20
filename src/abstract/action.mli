(* Copyright (C) 2013 Ben Lewis and David Donna *)
(* action.mli, part of TexterQuest *)
(* LGPLv3 *)

type t

type action =
  | Move of int
  | Cast of string
  | ActionError

val action_of_string : Actor.t -> string -> t

val string_of_action : t -> string

(* who's doing the action *)
val get_actor : t -> Actor.t

(* the tempo cost, if any, of the action *)
val get_cost : t -> int option

(* whether the action can be used in combat *)
val combat_compatible : t -> bool

(* whether the action can be used outside of combat *)
val noncombat_compatible : t -> bool

(* create an error (dummy) action for the actor in question *)
val error : Actor.t -> t

(* get the actual action (the thing done) *)
val get_action : t -> action
