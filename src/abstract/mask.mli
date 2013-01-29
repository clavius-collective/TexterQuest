type 'a mask
type 'a transform = 'a -> 'a
type 'a decay = 'a mask -> 'a mask option

module type MASKABLE = sig
  type t
  type acc
  val get_acc : t -> acc
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

module Mask : functor (M : MASKABLE) ->
  (MASK with type t = M.t and type acc = M.acc)

module Identity_acc : functor (M : sig
  type t
  val get_masks : t -> t mask list
  val set_masks : t -> t mask list -> unit
end) ->
  (MASK with type t = M.t and type acc = M.t)
