(* Copyright (C) 2013 Ben Lewis and David Donna *)
(* trait.ml, part of TexterQuest *)
(* LGPLv3 *)

type t =
  | TAspect    of Aspect.t
  | TAttribute of Attribute.t
  | TSkill     of Skill.t

let trait_of_aspect aspect = TAspect aspect
let trait_of_attribute attribute = TAttribute attribute
let trait_of_skill skill = TSkill skill
