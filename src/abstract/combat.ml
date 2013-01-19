(* Copyright (C) 2013 Ben Lewis and David Donna *)
(* combat.ml, part of TexterQuest *)
(* LGPLv3 *)

include Util

module Tempo = struct
  type acc = int
  type t = {
    generate_tempo : unit -> int;
    mutable masks  : acc Mask.mask list;
  }

  let create generator = {
    generate_tempo = generator;
    masks = [];
  }

  let get_base t : int = t.generate_tempo ()
  let get_masks t = t.masks
  let set_masks t masks = t.masks <- masks
end
 
module TempoMask = Mask.T (Tempo)

type t = {
  mutable tempo         : int;
  mutable balance       : int;
  mutable focus         : int;
  mutable queued_action : (int * Action.t) option;
  generator             : Tempo.t;
}

(* module state *)
let combat_lock = Mutex.create ()
let running = ref false
let in_combat = Hashtbl.create 100

let create actor =
  let generator_function () = 0 in
  let balance = 0 in
  let focus = 0 in
  let generator = Tempo.create generator_function in
  let tempo = TempoMask.get_value generator in
  let queued_action = None in
  {
    generator;
    tempo;
    balance;                            (* vary with tempo *)
    focus;                              (* vary against tempo *)
    queued_action;
  }

let submit_action = ignore

let locked f x =
  Mutex.lock combat_lock;
  let value = f x in
  Mutex.unlock combat_lock;
  value

let add_tempo t =
  let new_tempo = TempoMask.get_value t.generator in
  t.tempo <- t.tempo + new_tempo;
  if t.tempo > 0 then
    (match t.queued_action with
      | None -> ()
      | Some (cost, action) ->
          t.tempo <- t.tempo - cost;
          submit_action action)

let lookup = Hashtbl.find in_combat

let is_in_combat actor =
  try
    ignore (lookup actor);
    true
  with
    | Not_found -> false

let enter_combat actor =
  try ignore (lookup actor) with
    | Not_found ->
        let t = create actor in
        Hashtbl.add in_combat actor t

let queue_action = locked (fun actor cost action ->
  enter_combat actor;
  let t = lookup actor in
  if t.tempo > 0 then 
    (t.tempo <- t.tempo - cost;
     submit_action action)
  else
    t.queued_action <- Some (cost, action))

let leave_combat = locked (fun actor -> Hashtbl.remove in_combat actor)

let stop = locked (fun () -> running := false)

let start () =
  let react () =
    debug "combat thread starting";
    running := true;
    while !running do
      Thread.delay 0.5;
      Mutex.lock combat_lock;
      Hashtbl.iter (fun _ t -> add_tempo t) in_combat;
      Mutex.unlock combat_lock
    done
  in
  Thread.create react ()
