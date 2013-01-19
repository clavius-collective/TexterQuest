(* Copyright (C) 2013 Ben Lewis and David Donna *)
(* game.mli, part of TexterQuest *)
(* LGPLv3 *)

(* This module will be handling login, logout, character select, etc. *)

open Util

val process_input : username -> string -> unit
val player_login : username -> fstring
val player_select_character : (fstring -> unit) -> username -> int -> unit
val player_logout : username -> unit
