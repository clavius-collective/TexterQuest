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

let lookup vec trait = try List.assoc trait vec with Not_found -> new_stat ()

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
let all_values vec = List.map (fun (t, v) -> t, stat_value v) vec

let raw_value vec trait = truncate (lookup vec trait).value

let create ?(initial = []) traits =
  let init t = try List.assoc t initial with | Not_found -> 0.0 in
  List.map (fun t -> t, new_stat ~value:(init t) ()) traits

let aspect_vector ?initial () = create ?initial all_aspects
let attribute_vector ?initial () = create ?initial all_attributes
let skill_vector ?initial () = create ?initial all_skills
let trait_vector ?initial () = create ?initial all_traits

(* coefficient vectors can be appended!
   e.g. enchant = self @ static @ [`Enchant] *)
let check vec coeffs =
  let add total (trait, coeff) = total +. (float (value vec trait) *. coeff) in
  truncate (List.fold_left add 0.0 coeffs)

let combine_vectors vectors =
  let rec combine_pair acc left right = match left with
    | [] ->
        acc @ right
    | (trait, value)::left_rem ->
        let total, right_rem = 
          try
            value + List.assoc trait right, List.remove_assoc trait right
          with
            | Not_found -> value, right
        in
        combine_pair ((trait, total)::acc) left_rem right_rem
  in
  List.fold_left (combine_pair []) [] (List.map all_values vectors)
