open Util

type 'a mask = ('a -> 'a) * int

module T : functor (M : sig
  type acc
  type t
  val get_base : t -> acc
  val get_masks : t -> acc mask list
  val set_masks : t -> acc mask list -> unit
end) -> (sig
  val add_mask : M.t -> (M.acc -> M.acc) * int -> unit
  val get_value : M.t -> M.acc
end)
