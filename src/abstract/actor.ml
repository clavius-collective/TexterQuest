(* Copyright (C) 2013 Ben Lewis and David Donna *)
(* actor.ml, part of TexterQuest *)
(* LGPLv3 *)

include Util

let initial_location = "start"

type t = {
  name                 : string;
  wounds               : Wound.t;
  traits               : Trait.vector;
  send                 : fstring -> unit;
  mutable combat_stats : (int * int) option; (* balance, then focus *)
  mutable location     : room_id;  
}

(* 
 * Eventually split into create with labelled arguments for a loaded character,
 * and create_new to take a minimal set of arguments and flesh out the record.
 *)
let create ~wounds ~traits ~send ~location name  =
  {
    name;
    location;
    wounds;
    traits;
    send;
    combat_stats = None
  }

let create_new = create
  ~wounds:(Wound.create ())
  ~traits:(Trait.create_traits ())
  ~location:initial_location

let get_name t = t.name

let get_loc t = t.location

let set_loc t room_id = t.location <- room_id

let add_wound t = Wound.add_wound t.wounds

let get_wounds t = Wound.total_wounds t.wounds

let is_defeated t =
  let minor, middling, mortifying = get_wounds t in
  let sum = List.fold_left
    (fun smaller larger -> smaller / 3 + larger)
    0
    [minor; middling; mortifying]
  in
  sum > 2

let send t = t.send

let describe t = Raw t.name

let initial_focus t = 0
let initial_balance t = 0

let get_focus t = match t.combat_stats with
  | Some (_, focus) -> focus
  | None -> initial_focus t

let get_balance t = match t.combat_stats with
  | Some (balance, _) -> balance
  | None -> initial_balance t

let enter_combat t =
  t.combat_stats <- Some (initial_balance t, initial_focus t)

let leave_combat t =
  t.combat_stats <- None
