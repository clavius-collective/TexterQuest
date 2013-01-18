(* Copyright (C) 2013 Ben Lewis and David Donna *)
(* combat.mli, part of TexterQuest *)
(* LGPLv3 *)

val start : unit -> Thread.t
val stop : unit -> unit

(* 
 * Queue up an action. If the user has tempo, it will be submitted immediately
 * to the mutator for evaluation. Otherwise, it will be stored in this module's
 * state, and submitted once the actor in question has tempo.
 *)
val do_action : Actor.t -> int -> Action.t -> unit

(* instigated by the listener, when a user uses a combat action *)
val enter_combat : Actor.t -> unit

(* instigated by the mutator, when an actor flees or is defeated *)
(* to make this easier, maybe give the mutator a fights list? *)
val leave_combat : Actor.t -> unit
