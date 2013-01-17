(* Copyright (C) 2013 Ben Lewis and David Donna *)
(* combat.ml, part of TexterQuest *)
(* LGPLv3 *)

include Util

module Tempo = struct
  type acc = int
  type t = {
    generate_tempo : unit -> int;
    mutable masks : acc Mask.mask list;
  }

  let create generator =
    let generate_tempo = generator in
    let masks = [] in
    { generate_tempo; masks; }
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
  lock                  : Mutex.t;
}

let create ~generator ~balance ~focus =
  let lock = Mutex.create () in
  let generator = Tempo.create generator in
  let tempo = TempoMask.get_value generator in
  let queued_action = None in
  {
    generator;
    tempo;
    balance;                            (* vary with tempo *)
    focus;                              (* vary against tempo *)
    queued_action;
    lock;
  }

let new_tempo t = TempoMask.get_value t.generator

let submit_action = ignore

let locked f t =
  Mutex.lock t.lock;
  let value = f t in
  Mutex.unlock t.lock;
  value

let add_tempo = locked (fun t ->
  t.tempo <- t.tempo + new_tempo t;
  if t.tempo > 0 then
    (match t.queued_action with
      | None -> ()
      | Some (cost, action) ->
          t.tempo <- t.tempo - cost;
          submit_action action))

let do_action = locked (fun t cost action ->
  if t.tempo > 0 then 
    (t.tempo <- t.tempo - cost;
     submit_action action)
  else
    t.queued_action <- Some (cost, action))
