(* Copyright (C) 2013 Ben Lewis and David Donna *)
(* mask.ml, part of TexterQuest *)
(* LGPLv3 *)

(* TODO
 *   for serializability
 *     need: serializable mask type
 *     need: apply : mask -> base -> base
 *     provide: serializable decay type
 *)

include Util
include Sexplib
include Sexplib.Std

module type MASKABLE = sig
  type t with sexp
  type transform with sexp
    
  val apply_transform : transform -> t -> t
end

module type T = sig
  type t with sexp
  type base
  type transform
  type mask with sexp
  type decay = mask -> mask option      (* TODO: sexpify *)
      
  val on_base : (base -> 'a) -> t -> 'a
    
  val expires_after : int -> decay
    
  val compose :
    ?defer_same   : bool ->
    ?defer_change : bool ->
    ?defer_none   : bool ->
    decay                ->
    decay                ->
    decay
      
  val add_mask :
    description : fstring   ->
    transform   : transform ->
    decay       : decay     ->
    t                       ->
    unit

  val get_value : t -> base
end

module Make = functor (M : MASKABLE) -> (struct
  type base = M.t with sexp
  type transform = M.transform with sexp
  type decay = mask -> mask option

  and mask = {
    description : fstring;
    transform   : transform;
    decay       : decay;
  } with sexp

  type t = {
    base : base;
    mutable masks : mask list;
  } with sexp

  let on_base f x = f x.base

  let get_masks t = t.masks
  let set_masks t masks = t.masks <- masks

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
            | Some mask ->
                M.apply_transform mask.transform current, mask::active)
        (get_masks t)
        (t.base, [])
    in
    set_masks t active;
    final_val

  let add_mask ~description ~transform ~decay t =
    let mask =
      {
        description;
        transform;
        decay;
      }
    in
    set_masks t (mask::(get_masks t))
end : T with type base = M.t and type transform = M.transform)
