(* Copyright (C) 2013 Ben Lewis and David Donna *)
(* trait.mli, part of TexterQuest *)
(* LGPLv3 *)

open Types

type aspect = [
  `Solar  | `Lunar  | `Astral                 (* celestial                   *)
| `Frost  | `Bio    | `Terra  | `Aqua | `Aero (* natural                     *)
| `Ego    | `Ethos                            (* psychic                     *)
| `Shadow | `Light  | `Chroma                 (* chromatic                   *)
| `Flux   | `Static | `Chaos  | `Sync         (* synergistic                 *)
| `Life   | `Death                            (* cyclic                      *)
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
  `Enchant | `Alchemy                         (* magic                       *)
| `Melee   | `Ranged                          (* weapon                      *)
]

(* BOOM polymorphism motherfuckers                                           *)
type trait = [ aspect | attribute | skill ]

(*
 * List every value of the type in question.
 * 
 * NOTE: these will need to be changed manually if the types are extended
 *)
val all_aspects    : aspect list
val all_attributes : attribute list
val all_skills     : skill list
val all_traits     : trait list

(*
 * Tracks a player, room, or other object's association with a given trait.
 * e.g. degree of elemental affinity, skill proficiency, skill bonus, etc.
 * 
 * The values in a vector are stored as stat objects (which are hidden
 * behind this interface). This means that the values can be temporarily
 * altered with masks. The net value at a given moment can be accessed with
 * the values function.
 *)
type vector

(* Temporarily modify the value of a trait.                                  *)
val mask :
  vector       ->       (* the traits of the object in question              *)
  trait        ->       (* the id of the trait getting masked                *)
  (int -> int) ->       (* the effect (e.g. (+) 2 to increase by 2)          *)
  int          ->       (* the duration, in seconds, of the mask             *)
  unit

(* Look up the "visible" value of the trait for a given object's vector.     *)
val value : vector -> trait -> int

(* Return a list of the visible values of each trait in the vector.          *)
val all_values : vector -> (trait * int) list

(* 
 * Constructors that return a vector with a default initial value of 0.0 for
 * each trait of the named type. Traits associated with values in the
 * ~initial argument will have their stat initialized to those values. It is
 * safe to provide a partial list of initial values.
 *)
val aspect_vector    : ?initial : (aspect    * float) list -> unit -> vector
val attribute_vector : ?initial : (attribute * float) list -> unit -> vector
val skill_vector     : ?initial : (skill     * float) list -> unit -> vector
val trait_vector     : ?initial : (trait     * float) list -> unit -> vector

(* 
 * Given a list of vectors, produce a list mapping each trait present in at
 * least one of the vectors with the sum, across all of the vectors, of the
 * values for that trait.
 *)
val combine_vectors : vector list -> (trait * int) list

(* 
 * Take a linear combination of traits, and simplify it to an int. If the
 * same trait is associated with multiple coefficients (e.g. if the coeffs
 * are the result of a list concatenation), the final coefficient will be
 * the sum of those coefficients.
 *)
val check : 
  vector               ->               (* standard-issue stat vector        *)
  (trait * float) list ->               (* coefficients for trait check      *)
  int                                   (* truncate result (deterministic)   *)
