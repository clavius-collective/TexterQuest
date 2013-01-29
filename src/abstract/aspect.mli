type t

type conflict_stats = {
  degree    : float;
  synthesis : t;
}

(* get the total strength of the aspect affinity *)
val power            : t -> float

(* Add a higher-order aspect to the module state. *)
val new_aspect       : string -> (t * float) list -> t

(* 
 * Return a version of the aspect, with its power is adjusted proportionally.
 * If a target power is not set, the default is 1.0.
 *)
val normalize        : ?target : float -> t -> t

(* Throws Not_found if the string is invalid. *)
val aspect_of_string : string -> t

val string_of_aspect : t -> string

val conflict : t -> t -> conflict_stats
