type aspect = []
type attribute = []
type skill = []
type trait = [ aspect | attribute | skill ]

let all_aspects = []
let all_attribute = []
let all_skills = []
let all_traits = all_aspects @ all_attributes @ all_traits

let get_time () : int = truncate (Unix.time ())

type stat = {
  mutable value : float;
  mutable masks : ((int -> int) * int) list
}

let new_stat ?(value = 0.0) ?(masks = []) () = { value; masks; }

type vector = (trait, stat) Hashtbl.t

let lookup vec = Hashtbl.find vec

let mask vec trait func duration =
  let stat = (lookup vec trait) in
  let expire = duration + get_time () in
  stat.masks <- (func, expire)::stat.masks

let value vec trait =
  let stat = lookup vec trait in
  let time = get_time () in
  let final_val, masks =
    List.fold_right
      (fun ((func, expire) as mask) (total, active) ->
        if expire > time then
          func(total), mask::active
        else
          total, active)
      stat.masks
      (truncate stat.value, [])
  in
  stat.masks <- masks;
  final_val

let raw_value vec trait = truncate (lookup vec trait).value

let create ?(initial = []) traits =
  let table = Hashtbl.create 100 in
  List.iter
    (fun k -> Hashtbl.add table k (new_stat ()))
    traits;
  table

let check vec coeffs =
  List.fold_left
    (fun total (trait, coeff) -> total +. (float (lookup vec trait) *. coeff))
    0.0
    coeffs
