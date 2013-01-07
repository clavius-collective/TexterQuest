open Types

type player = string
val process_input : player -> string -> fstring
val player_login : player -> fstring
val player_logout : player -> unit
