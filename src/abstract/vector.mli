(* Copyright (C) 2013 Ben Lewis and David Donna *)
(* vector.mli, part of TexterQuest *)
(* LGPLv3 *)

(*
 * Tracks a player, room, or other object's association with a given trait.
 * e.g. degree of elemental affinity, skill proficiency, skill bonus, etc.
 *
 * The values in a vector are stored as stat objects (which are hidden
 * behind this interface). This means that the values can be temporarily
 * altered with masks. The net value at a given moment can be accessed with
 * the values function.
 *)
type 'a t

type mask = int Mask.mask

(* Temporarily modify the value of a trait.                                  *)
val add_mask :
  'a t               ->      (* the traits of the object in question         *)
  'a                 ->      (* the id of the trait getting masked           *)
  mask               ->      (* the effect (e.g. (+) 2 to increase by 2)     *)
  unit

(* Look up the "visible" value of the trait for a given object's vector.     *)
val get_value : 'a t -> 'a -> int

(* Return a list of the visible values of each trait in the vector.          *)
val all_values : 'a t -> ('a * int) list

val create :
  ?initial : ('a * float) list ->
  unit ->
  'a t

(*
 * Given a list of vectors, produce a list mapping each trait present in at
 * least one of the vectors with the sum, across all of the vectors, of the
 * values for that trait.
 *)
val combine_vectors : 'a t list -> ('a * int) list

(*
 * Take a linear combination of traits, and simplify it to an int. If the
 * same trait is associated with multiple coefficients (e.g. if the coeffs
 * are the result of a list concatenation), the final coefficient will be
 * the sum of those coefficients.
 *)
val check :
  'a t                 ->               (* standard-issue stat vector        *)
  ('a * float) list    ->               (* coefficients for trait check      *)
  int                                   (* truncate result (deterministic)   *)
