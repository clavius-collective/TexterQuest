type aspect = [
  `Solar  | `Lunar  | `Astral                 (* celestial *)
| `Frost  | `Bio    | `Terra  | `Aqua | `Aero (* natural *)
| `Ego    | `Ethos                            (* psychic *)
| `Shadow | `Light  | `Chroma                 (* chromatic *)
| `Flux   | `Static | `Chaos  | `Sync         (* synergistic *)
| `Life   | `Death                            (* cyclic *)
]

type attribute = [
  `Hardiness
| `Might
| `Mettle
| `Finesse
| `Agility
| `Stability
| `Resilience
| `Dedication
| `Concentration
| `Intuition
| `Clarity
]

type skill = [
  `Enchant | `Alchemy                   (* magic *)
| `Melee   | `Ranged                    (* weapon *)
]

type trait = [ aspect | attribute | skill ]

type stat = {
  mutable value : float;
  mutable masks : ((int -> int) * int) list
}

type vector = (trait * stat) list

let all_aspects = [
  `Solar; `Lunar; `Astral; `Frost; `Bio; `Terra; `Aqua; `Aero; `Ego; `Ethos;
  `Shadow; `Light; `Chroma; `Flux; `Static; `Chaos; `Sync; `Life; `Death;
]

let all_attributes = [
  `Hardiness; `Might; `Mettle; `Finesse; `Agility; `Stability; `Resilience;
  `Dedication; `Concentration; `Intuition; `Clarity;
]

let all_skills = [
  `Enchant; `Alchemy;
  `Melee; `Ranged
]

let all_traits = all_aspects @ all_attributes @ all_skills

let get_time () = truncate (Unix.time ())

let new_stat ?(value = 0.0) ?(masks = []) () = { value; masks; }

let lookup vec trait = List.assoc trait vec

let mask vec trait func duration =
  let stat = (lookup vec trait) in
  let expire = duration + get_time () in
  stat.masks <- (func, expire)::stat.masks

let stat_value stat =
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

let value vec trait = stat_value (lookup vec trait)

let raw_value vec trait = truncate (lookup vec trait).value

let create ?(initial = []) traits =
  let init t = try List.assoc t initial with | Not_found -> 0.0 in
  List.map (fun t -> t, new_stat ~value:(init t) ()) traits

let aspect_vector ?initial () = create ?initial all_aspects
let attribute_vector ?initial () = create ?initial all_attributes
let skill_vector ?initial () = create ?initial all_skills
let trait_vector ?initial () = create ?initial all_traits

let check vec coeffs =
  List.fold_left
    (fun total (trait, coeff) -> total +. (float (lookup vec trait) *. coeff))
    0.0
    coeffs

let add_vectors left right =
  let rec find acc left right = match left with
    | [] ->
        acc @ List.map (fun (t, s) -> t, stat_value s) right
    | (trait, stat)::left_rem ->
        let total_stat, right_rem = 
          try
            stat_value stat + stat_value (List.assoc trait right),
            List.remove_assoc trait right
          with
            | Not_found -> stat_value stat, right
        in
        find ((trait, total_stat)::acc) left_rem right_rem
  in
  find [] left right
