(* Copyright (C) 2013 Ben Lewis and David Donna *)
(* Licensed under LGPLv3 *)

(* Types for traits *)
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

let current_value actor trait =
  (* Get the current value (with "experience") from the actor, via cases. *)
  (* Take the floor of the current value, and return it. *)
 end

let current_step actor trait =
  (* Get the value of the trait from the actor; this can be handled in three
  cases, to deal with the different hashmaps involved. *)
  (* Determine the step involved by first getting the current value, then
  applying the formula we determine to find the step size. *)
 end

let add_experience actor trait quantity =
  (* Get the value of the trait out of the correct hashmap. *)
  (* Find the current step size *)
  (* Compute if there is an overflow to the next level.
   * - If so, add as much as necessary to overflow, then recompute step size
   *   and repeat the procedure for the new level.
   * - If not, add to current value.
   * Write the new value to the hashmap for the same trait.
   *)
 end
