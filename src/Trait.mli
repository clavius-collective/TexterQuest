(* Copyright (C) 2012 Ben Lewis and David Donna *)
(* Licensed under LGPLv3 *)

(* Enumerated types for Attributes, Skills, and Affinities *)
type attribute = Balance 
                 | Hardiness
                 | Might
                 | Mettle
                 | Finesse
                 | Agility
                 | Stability
                 | Resilience
                 | Dedication
                 | Concentration
                 | Intuition
                 | Clarity

type skill = Alchemy
             | Leatherworking

(* We need to work out a list of skills; unsure what all will go in it.  Those
 * can probably wait for a while.
 *)

      

type affinity = Solar
                | Lunar
                | Astral
                | Terra
                | Aqua
                | Aero
                | Bio
                | Frost
                | Ego
                | Ethos
                | Shadow
                | Light
                | Chroma
                | Flux
                | Static
                | Chaos
                | Sync
                | Life
                | Death

(* Variant type to work with all three types of traits. *)
type trait = Attribute of attribute
             | Skill of skill
             | Affinity of affinity
