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
let in_combat = Hashtbl.create 100
let running = ref false
let lock = Mutex.create ()
let locked f x =
    Mutex.lock lock;
    let value = f x in
    Mutex.unlock lock;
    value

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

let submit_action action = ignore action

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

let leave_combat = locked (Hashtbl.remove in_combat)

let queue_action = locked (fun action ->
  let actor = Action.get_actor action in
  let cost = Action.get_cost action in
  enter_combat actor;
  let t = lookup actor in
  if t.tempo > 0 then
    (t.tempo <- t.tempo - cost;
     submit_action action)
  else
    t.queued_action <- Some (cost, action))

let stop = locked (fun () -> running := false)

let start () =
  let react () =
    debug "combat thread starting";
    running := true;
    while !running do
      Thread.delay 0.5;
      (locked (Hashtbl.iter (fun _ t -> add_tempo t))) in_combat;
    done
  in
  Thread.create react ()
