(* Copyright (C) 2013 Ben Lewis and David Donna *)
(* trait.ml, part of TexterQuest *)
(* LGPLv3 *)

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

module StatMask = Mask.Masker(struct
  type acc = int
  type t = stat
  let get_base t = truncate t.value
  let get_masks t = t.masks
  let set_masks t m = t.masks <- m
end)

let new_stat ?(value = 0.0) ?(masks = []) () = { value; masks; }

let lookup vec trait =
  try List.assoc trait vec
  with Not_found -> new_stat ()

let mask vec trait mask =
  let stat = (lookup vec trait) in
  StatMask.add_mask stat mask

let raw_value vec trait = truncate (lookup vec trait).value
let get_value vec trait = StatMask.get_value (lookup vec trait)
let all_values vec = List.map (fun (t, v) -> t, StatMask.get_value v) vec

let create ?(initial = []) traits =
  let init t = 
    try List.assoc t initial
    with Not_found -> 0.0
  in
  List.map (fun t -> t, new_stat ~value:(init t) ()) traits

let create_aspects ?initial () = create ?initial all_aspects
let create_attributes ?initial () = create ?initial all_attributes
let create_skills ?initial () = create ?initial all_skills
let create_traits ?initial () = create ?initial all_traits

let check vec coeffs =
  let add total (trait, coeff) = total +. (float (get_value vec trait) *. coeff) in
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
