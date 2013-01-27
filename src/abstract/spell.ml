(* Copyright (C) 2013 Ben Lewis and David Donna *)
(* spell.ml, part of TexterQuest *)
(* LGPLv3 *)

include Util

type manipulation =
  | Damage
  | Heal
  | Mask of Trait.t * (int -> (Vector.stat_mask * int))

type aspect_relation =
  | Create
  | Destroy
  | Manipulate of manipulation

type an_effect = {
  aspect      : Aspect.t;
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
  | Any_syllable                        (* _ hack for combination list *)
  | No                                  (* null syllable *)
  | Erk                                 (* error syllable *)
                                                                               
let syllable_of_string s = match String.lowercase s with
  | "no" -> No
  | "_" -> Any_syllable
  | _ -> Erk

let spell_of_string s =
  let parts = split s in
  List.map syllable_of_string parts

let lock = Mutex.create ()
let combinations = ref [
  No, [No, [No, [Null]]];
]

let locked f x =
  Mutex.lock lock;
  let value = f x in
  Mutex.unlock lock;
  value

let generate_effect = locked (fun (syl1, syl2, syl3) ->
  let lookup elt collection =
    try
      List.assoc elt collection
    with
      | Not_found -> []
  in
  let of_syl syl lst = lookup syl lst @ lookup Any_syllable lst in
  match of_syl syl3 (of_syl syl2 (of_syl syl1 !combinations)) with
    | [] -> Null
    | first_match::_ -> first_match)

let add_effect = locked (fun str1 str2 str3 effect ->
  let get_syllable str = match syllable_of_string str with
    | Erk -> failwith ("mangled syllable: " ^ str)
    | s -> s
  in
  let syl1, syl2, syl3 = match List.map get_syllable [str1; str2; str3] with
    | [a; b; c] -> a, b, c
    | _ -> failwith "sanity check failed"
  in
  let rec add_third = function
    | (s, _)::xs when s = syl3    -> (syl3, [effect])::xs
    | x::xs                       -> x::(add_third xs)
    | []                          -> [syl3, [effect]]
  in
  let rec add_second = function
    | (s, next)::xs when s = syl2 -> (syl2, add_third next)::xs
    | x::xs                       -> x::(add_second xs)
    | []                          -> [syl2, [syl3, [effect]]]
  in
  let rec add_first = function
    | (s, next)::xs when s = syl1 -> (syl1, add_second next)::xs
    | x::xs                       -> x::(add_first xs)
    | []                          -> [syl1, [syl2, [syl3, [effect]]]]
  in
  combinations := add_first !combinations)

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
