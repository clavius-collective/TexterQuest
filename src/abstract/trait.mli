(* Copyright (C) 2013 Ben Lewis and David Donna *)
(* trait.mli, part of TexterQuest *)
(* LGPLv3 *)

open Util

type t =
| TAspect    of Aspect.t
| TAttribute of Attribute.t
| TSkill     of Skill.t


val trait_of_aspect    : Aspect.t    -> t
val trait_of_attribute : Attribute.t -> t
val trait_of_skill     : Skill.t     -> t
