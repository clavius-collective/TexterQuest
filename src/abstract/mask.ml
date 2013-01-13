(* Copyright (C) 2013 Ben Lewis and David Donna *)
(* mask.ml, part of TexterQuest *)
(* LGPLv3 *)

let get_time () = truncate (Unix.time ())

type 'a mask = ('a -> 'a) * int

module Masker = functor (M : sig
  type t
  type acc
  val get_base : t -> acc
  val get_masks : t -> acc mask list
  val set_masks : t -> acc mask list -> unit
end) -> struct

  let add_mask t func duration =
    let expire = duration + get_time () in
    M.set_masks t ((func, expire)::(M.get_masks t))

  let get_value t =
    let time = get_time () in
    let final_val, active =
      List.fold_right
        (fun ((func, expire) as mask) (total, active) ->
          if expire > time then
            func(total), mask::active
          else
            total, active)
        (M.get_masks t)
        (M.get_base t, [])
    in
    M.set_masks t active;
    final_val

end
