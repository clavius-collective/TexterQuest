(* Copyright (C) 2013 Ben Lewis and David Donna *)
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


(* Determines the current value of a trait *)
val current_value : Actor -> trait -> float

(* Determine the current experience step *)
val current_step : Actor -> trait -> float

(* Increase trait by a given amount of experience *)
val add_experience : Actor -> trait -> int -> unit

