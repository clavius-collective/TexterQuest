(* Copyright (C) 2013 Ben Lewis and David Donna *)
(* aspect.ml, part of TexterQuest *)
(* LGPLv3 *)

include Util

type core_aspect =
  | Solar | Lunar  | Astral
  | Frost | Earth  | Water  | Air
  | Light | Shadow | Chroma
  | Outer | Inner
  | Order | Chaos
  | Wax   | Wane
  | Bio   | Techne

type higher_order = {
  name       : string;
  components : (t * float) list;
}

and t =
  | Core   of core_aspect
  | Higher of higher_order

type conflict_stats = {
  degree    : float;
  synthesis : t;
}

(* TODO: state should include a DB connection *)
let higher_aspects = Hashtbl.create hash_size

let rec power = function
  | Core _ -> 1.0
  | Higher h ->
      List.fold_left
        (fun total (t, coeff) -> total +. ((power t) *. coeff))
        0.0
        h.components

let string_of_aspect = function
  | Core c -> (match c with
      | Solar  -> "Solar" | Lunar  -> "Lunar"  | Astral -> "Astral"
      | Frost  -> "Frost" | Earth  -> "Earth" 
      | Water  -> "Water" | Air    -> "Air"
      | Light  -> "Light" | Shadow -> "Shadow" | Chroma -> "Chroma"
      | Outer  -> "Outer" | Inner  -> "Inner"
      | Order  -> "Order" | Chaos  -> "Chaos"
      | Wax    -> "Wax"   | Wane   -> "Wane"
      | Bio    -> "Bio"   | Techne -> "Techne")
  | Higher h -> h.name

let get_components = function
  | Core c   -> [Core c, 1.0]
  | Higher h -> h.components

let conflict t1 t2 = match t1, t2 with
  (* TODO *)
  (* float representing degree of conflict *)
  (* aspect representing resolved combination *)
  (* internal conflict of dynamic aspect? *)
  | _, _ -> { degree = 0.0; synthesis = Core Solar }

(* will clobber by default *)
let new_aspect (name: string) (components: (t * float) list) =
  (* TODO: change this to a DB call *)
  Hashtbl.replace higher_aspects name components;
  Higher { name; components }

(* can throw Not_found *)
let core_of_string name = Core (List.assoc name [
  "Solar", Solar ; "Lunar" , Lunar  ; "Astral", Astral ;
  "Frost", Frost ; "Earth" , Earth  ; "Water" , Water  ; "Air", Air;
  "Light", Light ; "Shadow", Shadow ; "Chroma", Chroma ;
  "Outer", Outer ; "Inner" , Inner  ;
  "Order", Order ; "Chaos" , Chaos  ;
  "Wax"  , Wax   ; "Wane"  , Wane   ;
  "Bio"  , Bio   ; "Techne", Techne ;
])

(* can throw Not_found *)
let higher_of_string name =
  let components = Hashtbl.find higher_aspects name in
  Higher { name; components }

(* can throw Not_found *)
let aspect_of_string name =
  try
    core_of_string name
  with
    | Not_found -> higher_of_string name

let normalize ?(target=1.0) t = match t with
  | Core c -> t
  | Higher h ->
      let base_power = power t in
      let new_components = List.map
        (fun (t, coeff) -> t, coeff *. target /. base_power)
        h.components
      in
      Higher { h with components = new_components }

let affinities vec =
  let results = ref [] in
  let rec update (t, value) = match t with
    | Core _ as c -> 
        (try
           let v = List.assoc c !results in
           results := (c, value +. v)::(List.remove_assoc c !results)
         with
           | Not_found -> results := (c, value)::!results)
    | Higher h ->
        List.iter update h.components
  in
  List.iter update (List.flatten (List.map (get_components) vec));
  !results
