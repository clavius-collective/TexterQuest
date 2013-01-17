(* Copyright (C) 2013 Ben Lewis and David Donna *)
(* spell.mli, part of TexterQuest *)
(* LGPLv3 *)

open Util

type manipulation =
  | Damage
  | Heal
  | Mask of Trait.trait * (int -> int Mask.mask)

type aspect_relation =
  | Create
  | Destroy
  | Manipulate of manipulation

type an_effect = {
  aspect      : Trait.aspect;       (* the key element *)
  interaction : aspect_relation;    (* the actual effect *)
  power       : int;                (* raw power *)
  volatility  : float;              (* 0.0-1.0, multiplied by power *)
}

type effect =
  | Null                                (* no effect *)
  | Incant of string * int              (* compounding spells *)
  | AnEffect of an_effect               (* some effect *)
  | End                                 (* spell ended *)

val cast :
  Actor.t ->                            (* caster *)
  Object.t ->                           (* target *)
  string ->                             (* spell *)
  effect list                           (* spell effects *)
