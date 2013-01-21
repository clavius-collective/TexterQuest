(* Copyright (C) 2013 Ben Lewis and David Donna *)
(* mask.mli, part of TexterQuest *)
(* LGPLv3 *)

open Util

module type MASKED = sig
  type t                                (* the basic object *)
  type acc                              (* the type of the "value" *)
  type mask                             (* the type of the temporary mask *)

  (* Statefully adds the mask given, with its duration. *)
  val add_mask  : t -> mask * int -> unit

  (* Returns the "current value", factoring in all active masks. *)
  val get_value : t -> acc
end

(*
 * Provides masking functionality for a module, where the mask type is simply
 * a relation on the accumulator type.
 *)
module StandardMask : functor (M : sig
  type t
  type acc
  val get_base : t -> acc
  val get_masks : t -> ((acc -> acc) * int) list
  val set_masks : t -> ((acc -> acc) * int) list -> unit
end) ->
(MASKED with type t = M.t and type acc = M.acc and type mask = M.acc -> M.acc)

(*
 * Provides masking functionality with a given mask type, not necessarily a
 * relation on the accumulator type. Like StandardMask, except requires the
 * mask type, and an apply_mask function.
 *)
module WithMask : functor (M : sig
  type t
  type acc
  type mask
  val get_base : t -> acc
  val get_masks : t -> (mask * int) list
  val set_masks : t -> (mask * int) list -> unit
  val apply_mask : acc -> mask -> acc
end) ->
(MASKED with type t = M.t and type acc = M.acc and type mask = M.mask)

(* 
 * All features are provided, including a function that takes an expired mask
 * and potentially replaces it with another.
 *)
module WithReplace : functor (M : sig
  type t
  type acc
  type mask
  val get_base  : t -> acc
  val get_masks : t -> (mask * int) list
  val set_masks : t -> (mask * int) list -> unit
  val apply_mask : acc -> mask -> acc
  val replace   : (mask * int) -> (mask * int) option
end) ->
(MASKED with type t = M.t and type acc = M.acc and type mask = M.mask)
