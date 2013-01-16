(* Copyright (C) 2013 Ben Lewis and David Donna *)
(* game.ml, part of TexterQuest *)
(* LGPLv3 *)

include Util

(* 
   This module may need to be moved into actor.ml. Eventually, it would make
   sense to change Actor.t to Actor.actor, and set

     Actor.t = Noncombat of Actor.actor | Combat of Actor.actor * combat_traits

   This would let us efficiently check whether actors are in combat, which
   would be relevant for:
     * whether the actor "takes 10" on a spell or skill check
       * in this case, use Actor.initial_focus/initial_balance
       * or possibly some modification thereof? increase? 2x?
     * whether an NPC is already fighting something else
       * interaction with party system (if relevant)
       * not sure on what level parties would exist...
     * whether the actor can move to a different room
       * if in combat, require flee/victory before significant non-combat task

   An alternative would be to make it recursive with Actor; I would like to
   avoid this unless we can figure out how to tell OMake how to do it, since
   it would be cool to avoid manual build scripts. Really, REALLY cool.
*)

let tempo_generator actor () = 0
let initial_balance actor = 0
let initial_focus actor = 0

module Tempo = struct
  type acc = int

  type t = {
    generate_tempo : unit -> int;
    mutable masks : acc Mask.mask list;
  }

  let create actor =
    let generate_tempo = tempo_generator actor in
    let masks = [] in
    {
      generate_tempo;
      masks;
    }

  let get_base t : int = t.generate_tempo ()

  let get_masks t = t.masks

  let set_masks t masks = t.masks <- masks
end

module TempoMask = Mask.Masker(Tempo)

type combat_traits = {
  mutable tempo         : int;
  mutable balance       : int;
  mutable focus         : int;
  mutable queued_action : (int * Action.t) option;
  generator             : Tempo.t;
  lock                  : Mutex.t;
}

let create actor =
  let lock = Mutex.create () in
  let generator = Tempo.create actor in
  let tempo = TempoMask.get_value generator in
  let balance = initial_balance actor in
  let focus = initial_focus actor in
  let queued_action = None in
  {
    tempo;
    balance;                            (* vary with tempo *)
    focus;                              (* vary against tempo *)
    queued_action;
    lock;
    generator;
  }

let new_tempo t = TempoMask.get_value t.generator
let lock t = Mutex.lock t.lock
let unlock t = Mutex.unlock t.lock
let submit_action = ignore

let add_tempo t =
  lock t;
  t.tempo <- t.tempo + new_tempo t;
  if t.tempo > 0 then
    (match t.queued_action with
      | None -> ()
      | Some (cost, action) ->
          t.tempo <- t.tempo - cost;
          submit_action action);
  unlock t

let do_action t cost action =
  lock t;
  if t.tempo > 0 then (
    t.tempo <- t.tempo - cost;
    submit_action action)
  else
    t.queued_action <- Some (cost, action);
  unlock t
