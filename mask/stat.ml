let get_time () : int = truncate (Unix.time ())

type t = {
  mutable value : float;
  mutable masks : ((int -> int) * int) list
}

let add_mask t func duration =
  let expire = duration + get_time () in
  t.masks <- (func, expire)::t.masks

let value t =
  let time = get_time () in
  let final_val, masks =
    List.fold_right
      (fun ((func, expire) as mask) (total, active) ->
        if expire > time then
          func(total), mask::active
        else
          total, active)
      t.masks
      (truncate t.value, [])
  in
  t.masks <- masks;
  final_val

let raw_value t = truncate t.value
