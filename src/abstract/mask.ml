(* Copyright (C) 2013 Ben Lewis and David Donna *)
(* mask.ml, part of TexterQuest *)
(* LGPLv3 *)

include Util

module type MASKED = sig
  type t
  type acc
  type mask
  val add_mask  : t -> mask * int -> unit
  val get_value : t -> acc
end

module WithReplace = functor (M : sig
  type t
  type acc
  type mask
  val get_base : t -> acc
  val get_masks : t -> (mask * int) list
  val set_masks : t ->  (mask * int) list -> unit
  val apply_mask : acc -> mask -> acc
  val replace : (mask * int) -> (mask * int) option
end) -> struct
  include M

  let add_mask t (mask, duration) =
    let expire = duration + get_time () in
    M.set_masks t ((mask, expire)::(M.get_masks t))

  let get_value t =
    let time = get_time () in
    let final_val, active =
      List.fold_right
        (fun ((mask, expire) as timed) (total, active) ->
          if expire > time then
            M.apply_mask total mask, timed::active
          else
            match M.replace timed with
              | Some ((mask, _) as timed) ->
                  M.apply_mask total mask, timed::active
              | None -> total, active)
        (M.get_masks t)
        (M.get_base t, [])
    in
    M.set_masks t active;
    final_val
end

module WithMask = functor (M : sig
  type t
  type acc
  type mask
  val get_base : t -> acc
  val get_masks : t -> (mask * int) list
  val set_masks : t -> (mask * int) list -> unit
  val apply_mask : acc -> mask -> acc
end) -> WithReplace (struct
  include M
  let replace mask = None
end)

module StandardMask = functor (M : sig
  type t
  type acc
  val get_base : t -> acc
  val get_masks : t -> ((acc -> acc) * int) list
  val set_masks : t -> ((acc -> acc) * int) list -> unit
end) -> WithMask (struct
  include M
  type mask = M.acc -> M.acc
  let apply_mask acc mask = mask acc
end)
