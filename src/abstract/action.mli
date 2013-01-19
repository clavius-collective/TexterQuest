(* Copyright (C) 2013 Ben Lewis and David Donna *)
(* action.mli, part of TexterQuest *)
(* LGPLv3 *)

type action =
  | Move of int
  | Cast of string
  | ActionError

type t = Actor.t * action

(* These are two fairly straightforward functions; the second in particular for
   when NPCs do things. *)
val action_of_string : Actor.t -> string -> t

val string_of_action : t -> string

(* This is one of what will be a few ways of doing things in the game;
   this is the most basic, which does not produce any sort of output.
   It will be useful to have this sometimes, but generally we'll want
   a description of the t to be generated for the player's benefit. *)
(* val complete_action : t -> unit *)

val get_actor : t -> Actor.t
val get_cost : t -> int
