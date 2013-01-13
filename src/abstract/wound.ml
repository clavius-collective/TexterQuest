(* Copyright (C) 2013 Ben Lewis and David Donna *)
(* wound.ml, part of TexterQuest *)
(* LGPLv3 *)

type severity =
  | Minor 
  | Middling
  | Mortifying

type totals = int * int * int
type wounds = totals Mask.mask list ref

module WMask = Mask.Masker (struct
  type t = wounds
  type acc = totals
  let get_base t = (0, 0, 0)
  let get_masks = (!)
  let set_masks t m = t := m
end)

let create () = ref []

let add_wound t severity duration =
  let wound_function = match severity with
    | Minor -> fun (a, b, c) -> a + 1, b, c
    | Middling -> fun (a, b, c) -> a, b + 1, c
    | Mortifying -> fun (a, b, c) -> a, b, c + 1
  in
  WMask.add_mask t wound_function duration

let total_wounds = WMask.get_value
