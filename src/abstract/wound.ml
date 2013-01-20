(* Copyright (C) 2013 Ben Lewis and David Donna *)
(* wound.ml, part of TexterQuest *)
(* LGPLv3 *)

include Util

type severity =
  | Minor 
  | Middling
  | Mortifying

let new_wound ?duration ?(discount=0) severity =
  let now = get_time () in
  let duration = match duration with
    | Some d -> d
    | None -> (match severity with
        (* default durations *)
        | Minor -> 60
        | Middling -> 120
        | Mortifying -> 360)
  in
  let expire = now + duration - discount in
  severity, expire

module W = struct
  type acc = (int * int * int)
  type mask = severity
  type t = (mask * int) list ref
  let get_base t = (0, 0, 0)
  let get_masks = (!)
  let set_masks t l = t := l

  let rec replace (severity, expire) =
    let now = get_time () in
    if expire > now then
      Some (severity, expire)
    else
      let discount = now - expire in
      match severity with
        | Minor -> None                   (* fully healed *)
        | Middling
        | Mortifying -> 
            (* serious wounds heal to the next less serious level *)
            let new_severity = (match severity with
              | Minor -> failwith "sanity check failed"
              | Middling -> Minor
              | Mortifying -> Middling)
            in
            let (_, new_expire) as wound = (new_wound ~discount new_severity) in
            if new_expire > now then
              Some wound
            else
              (* wound has healed by more than one severity level *)
              replace wound

  let apply_mask (a, b, c) = function
    | Minor      -> (a + 1, b, c)
    | Middling   -> (a, b + 1, c)
    | Mortifying -> (a, b, c + 1)
end

module WMask = Mask.TReplace(W)

include W

let add_wound t ?duration ?discount severity =
  let wound = new_wound ?duration ?discount severity in
  t << wound

let total_wounds = WMask.get_value

let create () = ref []
