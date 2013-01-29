(* Copyright (C) 2013 Ben Lewis and David Donna *)
(* mutator.ml, part of TexterQuest *)
(* LGPLv3 *)

include Util

let actions : Action.t Queue.t = Queue.create ()
let condition = Condition.create ()
let lock = Mutex.create ()
let locked f x =
  Mutex.lock lock;
  let value = f x in
  Mutex.unlock lock;
  value

let submit = locked (fun action ->
  debug ("action submitted for " ^ (Actor.get_name (Action.get_actor action)));
  Queue.add action actions;
  Condition.signal condition)

let handle_action action = 
  let open Action in
      let character = Action.get_actor action in
      Actor.send character (match Action.get_action action with
        | Move i -> Room.move character i
        | Cast spell -> Raw "cast a spell"
        | ActionError -> Raw "INVALID COMMAND")

let start () =
  debug "mutator starting";
  let ready = Queue.create () in
  let process_actions () =
    while true do
      Mutex.lock lock;
      Condition.wait condition lock;
      Queue.transfer actions ready;
      Mutex.unlock lock;
      Queue.iter handle_action ready;
      Queue.clear ready
    done
  in
  ignore (Thread.create process_actions ())
