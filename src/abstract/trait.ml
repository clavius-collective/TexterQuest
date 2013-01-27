(* Copyright (C) 2013 Ben Lewis and David Donna *)
(* trait.ml, part of TexterQuest *)
(* LGPLv3 *)

type t = [
  `Aspect    of Aspect.t
| `Attribute of Attribute.t
| `Skill     of Skill.t
]

let trait_of_aspect aspect = `Aspect aspect
let trait_of_attribute attribute = `Attribute attribute
let trait_of_skill skill = `Skill skill
