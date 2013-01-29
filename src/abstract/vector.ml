(* Copyright (C) 2013 Ben Lewis and David Donna *)
(* vector.ml, part of TexterQuest *)
(* LGPLv3 *)

include Util

type mask = int Mask.mask

type stat = {
  mutable value : float;
  mutable masks : mask list
}

type 'a t = ('a * stat) list ref

module StatMask = Mask.Make (struct
  type t = stat
  type acc = int
  let get_acc t = truncate t.value
  let get_masks t = t.masks
  let set_masks t m = t.masks <- m
end)

let new_stat ?(value = 0.0) ?(masks = []) () = { value; masks; }

let lookup t trait =
  try 
    List.assoc trait !t
  with 
    | Not_found ->
        let s = new_stat () in
        t := (trait, s)::!t;
        s

let add_mask vec trait mask =
  let stat = (lookup vec trait) in
  StatMask.add_mask stat mask

let raw_value vec trait = truncate (lookup vec trait).value
let get_value vec trait = StatMask.get_value (lookup vec trait)
let all_values t = List.map (fun (trait, v) -> trait, StatMask.get_value v) !t

let create ?(initial = []) traits =
  ref (List.map (fun (trait, value) -> trait, new_stat ~value ()) initial)

let check vec coeffs =
  let add total (trait, coeff) =
    total +. (float (get_value vec trait) *. coeff)
  in
  truncate (List.fold_left add 0.0 coeffs)

let combine_vectors vectors =
  let rec combine_two_vectors acc left right = match left with
    | [] ->
        acc @ right
    | (trait, value)::left_rem ->
        let total, right_rem = 
          try
            value + List.assoc trait right, List.remove_assoc trait right
          with
            | Not_found -> value, right
        in
        combine_two_vectors ((trait, total)::acc) left_rem right_rem
  in
  List.fold_left (combine_two_vectors []) [] (List.map all_values vectors)
