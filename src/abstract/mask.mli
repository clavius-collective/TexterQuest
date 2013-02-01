(* Copyright (C) 2013 Ben Lewis and David Donna *)
(* mask.mli, part of TexterQuest *)
(* LGPLv3 *)

type 'a mask

(*
 * After a brief time as an abstract type, wounds have been restored to a
 * relation on the accumulator type. (That is, the type returned by get_value,
 * e.g. int for stats.)
 *)
type 'a transform = 'a -> 'a

(* 
 * Function that will return whatever form the mask has, or None if the mask
 * has simply expired. An example would be a wound's decay function returning a
 * less serious wound after it has healed for some time.
 * 
 * The reason this takes a mask instead of unit is to allow de facto
 * introspection. When a mask is checked for decay, it will be passed as the
 * argument to its own decay function. Critically, this allows the decay
 * function to return the mask itself, signifying no change.
 *)
type 'a decay = 'a mask -> 'a mask option

module type MASKABLE = sig
  type t   (* The type of the object to which masks will be added. *)
  type acc (* The type to be returned by get_value. *)

  (* The base value for masking. *)
  val get_acc   : t -> acc

  val get_masks : t -> acc mask list

  val set_masks : t -> acc mask list -> unit
end

module type MASK = sig
  include MASKABLE

  (*
   * Create a simple decay function that will leave a mask unchanged until the
   * specified number of seconds has passed. At that point, the mask simply
   * expires. Using this as the first argument to a compose call, with the
   * defer_none flag set, will suspend the other decay function for the same
   * duration.
   * 
   * Note that the duration is calculated from the moment the decay function is
   * returned by this function. If you create several decay functions at once,
   * e.g. to create a progressive transformation, they will all start aging at
   * the same time.
   *)
  val expires_after : int -> acc decay

  (*
   * Given two decay functions, return a decay function which starts by
   * applying the first (decay) to the argument mask. If the defer_* flag
   * corresponding to the return value is set to true, take the result (in the
   * Some cases) or the original mask (in the None) case, and apply the second
   * decay function (decay') to it, then return the result of that call.
   * 
   * The defer flags are all false by default, indicating that decay' will not
   * be applied at all unless one or more are manually set to true.
   *)
  val compose :
    ?defer_same   : bool -> (* apply decay' if the mask is unchanged         *)
    ?defer_change : bool -> (* apply decay' if some other mask is returned   *)
    ?defer_none   : bool -> (* apply decay' to the mask if it expires        *)
    acc decay            ->
    acc decay            ->
    acc decay

  val create :
    description : string        ->
    transform   : acc transform ->
    decay       : acc decay     ->
    acc mask

  val add_mask  : t -> acc mask -> unit

  val get_value : t -> acc
end

module Make : functor (M : MASKABLE) ->
  (MASK with type t = M.t and type acc = M.acc)

module Identity_acc : functor (M : sig
  type t
  val get_masks : t -> t mask list
  val set_masks : t -> t mask list -> unit
end) ->
  (MASK with type t = M.t and type acc = M.t)
