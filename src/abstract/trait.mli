type aspect = [
  `Solar  | `Lunar  | `Astral                 (* celestial *)
| `Frost  | `Bio    | `Terra  | `Aqua | `Aero (* natural *)
| `Ego    | `Ethos                            (* psychic *)
| `Shadow | `Light  | `Chroma                 (* chromatic *)
| `Flux   | `Static | `Chaos  | `Sync         (* synergistic *)
| `Life   | `Death                            (* cyclic *)
]

type attribute = [
  `Might
| `Mettle
| `Chutzpah
]

type skill = [
  `Enchant | `Alchemy                   (* magic *)
| `Melee | `Ranged                      (* weapon *)
]

type trait = [ aspect | attribute | skill ]

type vector

val mask : vector -> trait -> (int -> int) -> int -> unit
val value : vector -> trait -> int

val aspect_vector : ?initial : (aspect * float) list -> unit -> vector
val attribute_vector : ?initial : (attribute * float) list -> unit -> vector
val skill_vector : ?initial : (skill * float) list -> unit -> vector
val trait_vector : ?initial : (trait * float) list -> unit -> vector
