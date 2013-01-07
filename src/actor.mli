open Types

type t
    
val create : string -> room_id -> t
val get_name : t -> string
val get_loc : t -> room_id
val set_loc : t -> room_id -> unit
