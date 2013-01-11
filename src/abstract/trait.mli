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

val all_aspects : aspect list
val all_attributes : attribute list
val all_skills : skill list
val all_traits : trait list

type vector

val mask : vector -> trait -> (int -> int) -> int -> unit
val value : vector -> trait -> int

val aspect_vector : ?initial : (aspect * float) list -> unit -> vector
val attribute_vector : ?initial : (attribute * float) list -> unit -> vector
val skill_vector : ?initial : (skill * float) list -> unit -> vector
val trait_vector : ?initial : (trait * float) list -> unit -> vector

val add_vectors : vector -> vector -> (trait * int) list
