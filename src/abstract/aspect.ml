(* Copyright (C) 2013 Ben Lewis and David Donna *)
(* aspect.ml, part of TexterQuest *)
(* LGPLv3 *)

(* state should include a DB connection *)

type core_aspect =
  | Solar | Lunar  | Astral
  | Frost | Earth  | Water | Air
  | Light | Shadow | Chroma
  | Other | Self
  | Order | Chaos
  | Wax   | Wane
  | Bio   | Techne

type higher_order = {
  name       : string;
  components : (t * float) list;
}

and t =
  | Core of core_aspect
  | Higher of higher_order

let rec power = function
  | Core _ -> 1.0
  | Higher h ->
      List.fold_left
        (fun total (t, coeff) -> total +. ((power t) *. coeff))
        0.0
        h.components

let string_of_aspect = function
  | Core c -> (match c with
      | Solar  -> "solar" | Lunar  -> "lunar"  | Astral -> "astral"
      | Frost  -> "frost" | Earth  -> "earth" 
      | Water  -> "water" | Air    -> "air"
      | Light  -> "light" | Shadow -> "shadow" | Chroma -> "chroma"
      | Other  -> "other" | Self   -> "self"
      | Order  -> "order" | Chaos  -> "chaos"
      | Wax    -> "wax"   | Wane   -> "wane"
      | Bio    -> "bio"   | Techne -> "techne")
  | Higher h -> h.name

let conflict t1 t2 = match t1, t2 with
  (* float representing degree of conflict *)
  (* aspect representing resolved combination *)
  (* internal conflict of dynamic aspect? *)
  | _, _ -> 0.0

let new_aspect name components =
  (* add to database *)
  { name; components }

let normalize t = match t with
  | Core c -> t
  | Higher h ->
      let pow = power t in
      let new_components =
        List.map (fun (t, coeff) -> t, coeff /. pow) h.components
      in
      Higher { h with components = new_components }
