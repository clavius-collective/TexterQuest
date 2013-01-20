(* Copyright (C) 2013 Ben Lewis and David Donna *)
(* mask.mli, part of TexterQuest *)
(* LGPLv3 *)

open Util

module StandardMask : functor (M : sig
  type t
  type acc
  val get_base : t -> acc
  val get_masks : t -> ((acc -> acc) * int) list
  val set_masks : t -> ((acc -> acc) * int) list -> unit
end) -> (sig
  val add_mask  : M.t -> (M.acc -> M.acc) * int -> unit
  val get_value : M.t -> M.acc
end)

module WithMask : functor (M : sig
  type t
  type acc
  type mask
  val get_base : t -> acc
  val get_masks : t -> (mask * int) list
  val set_masks : t -> (mask * int) list -> unit
  val apply_mask : acc -> mask -> acc
end) -> (sig
  val add_mask  : M.t -> M.mask * int -> unit
  val get_value : M.t -> M.acc
end)

module WithReplace : functor (M : sig
  type t
  type acc
  type mask
  val get_base  : t -> acc
  val get_masks : t -> (mask * int) list
  val set_masks : t -> (mask * int) list -> unit
  val apply_mask : acc -> mask -> acc
  val replace   : (mask * int) -> (mask * int) option
end) -> (sig
  val add_mask  : M.t -> M.mask * int -> unit
  val get_value : M.t -> M.acc
end)
