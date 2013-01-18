val start : unit -> Thread.t
val stop : unit -> unit

val do_action : Actor.t -> int -> Action.t -> unit

(* instigated by the listener, when a user uses a combat action *)
val enter_combat : Actor.t -> unit

(* instigated by the mutator, when an actor flees or is defeated *)
(* to make this easier, maybe give the mutator a fights list? *)
val leave_combat : Actor.t -> unit
