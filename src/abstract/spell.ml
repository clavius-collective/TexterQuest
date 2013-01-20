(* Copyright (C) 2013 Ben Lewis and David Donna *)
(* spell.ml, part of TexterQuest *)
(* LGPLv3 *)

include Util

type manipulation =
  | Damage
  | Heal
  | Mask of Trait.trait * (int -> (Trait.stat_mask * int))

type aspect_relation =
  | Create
  | Destroy
  | Manipulate of manipulation

type an_effect = {
  aspect      : Trait.aspect;
  interaction : aspect_relation;
  power       : int;
  volatility  : float;
}

type spell_effect =
  | Null                                (* no effect *)
  | Incant of string * int              (* compounding spells *)
  | AnEffect of an_effect               (* some effect *)
  | End                                 (* spell ended *)

type syllable =
  | No                                  (* null syllable *)
  | Erk                                 (* error syllable *)
                                                                               
let spell_of_string s =
  let syllable_of_string s = match String.lowercase s with
    | "no" -> No
    | _ -> Erk
  in
  let parts = split s in
  List.map syllable_of_string parts

(* helper function to determine spell effects based on
   each subsequence of three syllables in the spell *)
let generate_effect = function
  | No, No, No -> Null
  (* cases for different syllables/effects *)
  | _ -> End

(* Ignore subsequences with no effect, truncate effects
   list if an end sequence occurred. *)
let rec process actor effects (a, b, c) = function
  (* keep track of focus cost
     keep track of actor's focus
     nondeterminism
     diminishing returns
     question: elemental affinities here, or in resolution?
     maybe just use a record to keep track of this shit
  *)
  | []
  | End::_ -> effects
  | Null::xs -> process actor effects (b, c, Null) xs
  | (Incant (incantation, level))::xs ->
      (* FIX MANTRA FOLD LOGIC *)
      []
  | (AnEffect e)::xs ->
      process actor ((AnEffect e)::effects) (b, c, AnEffect e) xs

(* syllable list -> effect list *)
let cast actor target spell =    
  let syllables = spell_of_string spell in
  (* process spell, make a list of the effects of each
     group of three subsequent syllables *)
  let base_effects, _ = List.fold_left
    (fun (acc, (a ,b, c)) next ->
      let new_tail = b, c, next in
      (generate_effect new_tail)::acc, new_tail)
    ([], (No, No, No))
    syllables
    in
  process actor [] (Null, Null, Null) base_effects
(* 
   The result of this will be applied differently for
   * straight cast
   * enchantment
   * alchemy?
*)
