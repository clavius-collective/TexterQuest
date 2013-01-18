(* Copyright (C) 2013 Ben Lewis and David Donna *)
(* combat.mli, part of TexterQuest *)
(* LGPLv3 *)

(*
 * Here's the problem: something will have to keep track of which actors are in
 * combat with which. This is necessary for AI aggro, but also to determine who
 * leaves combat when a fight ends.
 *)

val start : unit -> Thread.t
val stop : unit -> unit

(* 
 * Queue up an action. If the user has tempo, it will be submitted immediately
 * to the mutator for evaluation. Otherwise, it will be stored in this module's
 * state, and submitted once the actor in question has tempo.
 * 
 * NOTE: Action.t will eventually have functions to extract the actor and cost,
 * so this will only need one argument.
 *)
val queue_action :
  Actor.t  ->                  (* the actor performing the action            *)
  int      ->                  (* the cost of the action (combat only)       *)
  Action.t ->                  (* the action itself                          *)
  unit

(* simple check; may be obviated in most cases *)
val is_in_combat : Actor.t -> bool

(* 
 * Called automatically for do_action, so this function need only be called
 * explicitly when an actor is attacked. If the actor is already in combat,
 * the function will abort gracefully, so redundant calls are okay.
 *)
val enter_combat : Actor.t -> unit

(* 
 * Instigated by the mutator, when an actor flees or is defeated. If the actor
 * is already out of combat, this function will abort gracefully.
 *)
val leave_combat : Actor.t -> unit
