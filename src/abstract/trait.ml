(* Copyright (C) 2013 Ben Lewis and David Donna *)
(* trait.ml, part of TexterQuest *)
(* LGPLv3 *)

type t = [
  `Aspect    of Aspect.t
| `Attribute of Attribute.t
| `Skill     of Skill.t
]
