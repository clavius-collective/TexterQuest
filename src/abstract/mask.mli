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
 *)
type 'a decay = 'a mask -> 'a mask option

module type MASKABLE = sig
  type t
  type acc
  val get_acc   : t -> acc
  val get_masks : t -> acc mask list
  val set_masks : t -> acc mask list -> unit
end

module type MASK = sig
  type t
  type acc

  val expires_after : int -> acc decay

  val compose :
    ?defer_same   : bool ->
    ?defer_change : bool ->
    ?defer_none   : bool ->
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
