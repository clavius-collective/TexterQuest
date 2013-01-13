(* Copyright (C) 2013 Ben Lewis and David Donna *)
(* wound.mli, part of TexterQuest *)
(* LGPLv3 *)

(* subject to change                                                         *)
type severity =
  | Minor 
  | Middling
  | Mortifying

(* the object that tracks a given actor's wounds                             *)
type wounds

val create : unit -> wounds

(* adds a wound                                                              *)
val add_wound : 
  wounds ->                             (* the actor's current wounds        *)
  severity ->                           (* the severity of the new wound     *)
  int ->                                (* the new wound's duration          *)
  unit

val total_wounds :
  wounds ->
  (int * int * int)                     (* the total numbers of wounds, in
                                           increasing order of severity      *)
