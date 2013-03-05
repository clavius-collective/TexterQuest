(** *)

(** Translate user input into an intended action. The syntax is described in
    the commandparse.mly ocamlyacc file, 
    
*)
val get_command : string -> Action.command
