(* Copyright (C) 2013 Ben Lewis and David Donna *)
(* spell.mli, part of TexterQuest *)
(* LGPLv3 *)

open Util

type manipulation =
  | Damage
  | Heal
  | Mask of Trait.t * Vector.mask

type aspect_relation =
  | Create
  | Destroy
  | Manipulate of manipulation

type an_effect = {
  aspect      : Aspect.t;           (* the key element *)
  interaction : aspect_relation;    (* the actual effect *)
  power       : int;                (* raw power *)
  volatility  : float;              (* 0.0-1.0, multiplied by power *)
}

type spell_effect =
  | Null                                (* no effect *)
  | Incant   of string * int            (* compounding spells *)
  | AnEffect of an_effect               (* some effect *)
  | End                                 (* spell ended *)

val cast :
  Actor.t  ->                           (* caster *)
  Object.t ->                           (* target *)
  string   ->                           (* spell *)
  spell_effect list                     (* spell effects *)

(*
 * Given the names of three syllables and a spell effect, associate the effect
 * given with those syllables, in that order. If more than one of the patterns
 * added matches a sequence of syllables in a given spell, the one that gets
 * applied is based on specificity of the pattern. Patterns that accept only
 * one syllable in the first slot will take precedence over those accepting any
 * syllable, then likewise for the second and third slots.
 * 
 * RAISES AN EXCEPTION if any of the syllables is mangled.
 *)
val add_effect :
  string -> string -> string ->        (* the syllables in question *)
  spell_effect ->                      (* the effect to result *)
  unit
