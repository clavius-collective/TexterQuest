(* Copyright (C) 2013 Ben Lewis and David Donna *)
(* Action.mli, part of TexterQuest *)
(* LGPLv3 *)

type t = Move of Actor.t * Room.t
         | Error

(* These are two fairly straightforward functions; the second in particular for
   when NPCs do things. *)
val action_of_string : string -> Actor.t -> action

val string_of_action : action -> string

(* This is one of what will be a few ways of doing things in the game; this is
   the most basic, which does not produce any sort of output.  It will be useful
   to have this sometimes, but generally we'll want a description of the action
   to be generated for the player's benefit. *)
(* val complete_action : action -> unit *)
