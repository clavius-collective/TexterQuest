(* Copyright (C) 2013 Ben Lewis and David Donna *)
(* wound.mli, part of TexterQuest *)
(* LGPLv3 *)

(* subject to change                                                         *)
type severity =
  | Minor 
  | Middling
  | Critical

(* the object that tracks a given actor's wounds                             *)
type t

val create : unit -> t

(* adds a wound                                                              *)
val add_wound : 
  t          ->                     (* the actor's current wounds            *)
  ?delay:int ->                     (* the duration of the wound             *)
  severity   ->                     (* the severity of the new wound         *)
  unit

(* return the total number of wounds at each degree of severity (increasing) *)
val total_wounds : t -> (int * int * int)
