(** Handles actions attempted by actors (both players and NPCs). *)

(** Low-level abstraction of a player's input, resulting from basic parsing.
    The targets of the action (e.g. of a spell) are still given as raw strings,
    so that the command creation process does not require getting information
    from the actual game state. A command is later converted into an action. *)
type command with sexp

val make_command : string -> string list -> string list -> command
