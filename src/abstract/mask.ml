include Util

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

and 'a mask = {
  description : string;
  transform   : 'a -> 'a;
  decay       : 'a decay;
}

(* 
 * possible TODO: add
 *   type mask'
 *   val application_of_mask' : mask' -> 'a mask
 * (with the names changed around so that it makes more sense)
 *)
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

  val create    :
    description : string        ->
    transform   : acc transform ->
    decay       : acc decay     ->
    acc mask

  val add_mask  : t -> acc mask -> unit

  val get_value : t -> acc
end

module Mask = functor (M : MASKABLE) -> struct
  include M
        
  let expires_after duration =
    let expiration = get_time () + duration in
    (fun mask ->
      let now = get_time () in
      if now < expiration then Some mask else None)

  let compose
      ?(defer_same   = false)
      ?(defer_change = false)
      ?(defer_none   = false)
      decay decay' mask =
    match decay mask with
      | Some mask' when mask' == mask ->
          if defer_same   then decay' mask' else Some mask'
      | Some mask' ->
          if defer_change then decay' mask' else Some mask'
      | None ->
          if defer_none   then decay' mask  else None

  let decays_after duration = compose ~defer_none:true (expires_after duration)

  let check_decay mask = mask.decay mask

  let get_value t =
    let final_val, active =
      List.fold_right
        (fun mask (current, active) ->
          match check_decay mask with
            | None -> current, active
            | Some mask -> mask.transform current, mask::active)
        (M.get_masks t)
        (M.get_acc t, [])
    in
    M.set_masks t active;
    final_val

  let create ~description ~transform ~decay =
    {
      description;
      transform;
      decay;
    }

  let add_mask t mask =
    M.set_masks t (mask::(M.get_masks t))
end

module Identity_acc = functor (M : sig
  type t
  val get_masks : t -> t mask list
  val set_masks : t -> t mask list -> unit
end) -> Mask (struct
  include M
  type acc = t
  let get_acc t = t
end)
