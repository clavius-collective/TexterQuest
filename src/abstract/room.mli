open Types 

val create : room_id -> string -> (room_id * string) array -> unit
 
val leave : Actor.t -> unit
val enter : Actor.t -> room_id -> fstring
val move : Actor.t -> int -> fstring
   
val list_actors : room_id -> fstring
val list_exits : room_id -> fstring
val describe : room_id -> fstring
