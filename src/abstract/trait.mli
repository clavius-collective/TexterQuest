(* Copyright (C) 2013 Ben Lewis and David Donna *)
(* trait.mli, part of TexterQuest *)
(* LGPLv3 *)

open Util

type t = [
  `Aspect    of Aspect.t
| `Attribute of Attribute.t
| `Skill     of Skill.t
]

val trait_of_aspect    : Aspect.t    -> t
val trait_of_attribute : Attribute.t -> t
val trait_of_skill     : Skill.t     -> t
