(* Copyright (C) 2013 Ben Lewis and David Donna *)
(* game.mli, part of TexterQuest *)
(* LGPLv3 *)

open Types

val process_input : username -> string -> fstring
val player_login : username -> fstring
val player_select_character : username -> int -> fstring
val player_logout : username -> unit
