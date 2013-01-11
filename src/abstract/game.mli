open Types

val process_input : username -> string -> fstring
val player_login : username -> fstring
val player_select_character : username -> int -> fstring
val player_logout : username -> unit
