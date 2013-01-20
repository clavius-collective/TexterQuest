(* Copyright (C) 2013 Ben Lewis and David Donna *)
(* mask.ml, part of TexterQuest *)
(* LGPLv3 *)

include Util

module WithReplace = functor (M : sig
  type t
  type acc
  type mask
  val get_base : t -> acc
  val get_masks : t -> (mask * int) list
  val set_masks : t ->  (mask * int) list -> unit
  val replace : (mask * int) -> (mask * int) option
  val apply_mask : acc -> mask -> acc
end) -> struct
  let add_mask t (func, duration) =
    let expire = duration + get_time () in
    M.set_masks t ((func, expire)::(M.get_masks t))

  let get_value t =
    let time = get_time () in
    let final_val, active =
      List.fold_right
        (fun ((func, expire) as mask) (total, active) ->
          if expire > time then
            M.apply_mask total func, mask::active
          else
            match M.replace mask with
              | Some ((func, _) as mask) ->
                  M.apply_mask total func, mask::active
              | None -> total, active)
        (M.get_masks t)
        (M.get_base t, [])
    in
    M.set_masks t active;
    final_val
end

module NoneReplace = functor (M : sig
  type t
  type acc
  type mask
  val get_base : t -> acc
  val get_masks : t -> ((acc -> acc) * int) list
  val set_masks : t -> ((acc -> acc) * int) list -> unit
  val apply_mask : acc -> mask -> acc
end) -> (struct
  include M
  let replace mask = None
end)

module StandardMask = functor (M : sig
  type t
  type acc
  val get_base : t -> acc
  val get_masks : t -> ((acc -> acc) * int) list
  val set_masks : t -> ((acc -> acc) * int) list -> unit
end) -> (struct
  include M
  type mask = M.acc -> M.acc
  let apply_mask acc mask = mask acc
end)

module T = functor (M : sig
  type t
  type acc
  val get_base : t -> acc
  val get_masks : t -> ((acc -> acc) * int) list
  val set_masks : t -> ((acc -> acc) * int) list -> unit
end) -> WithReplace (NoneReplace (StandardMask (M)))
