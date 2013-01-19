(* Copyright (C) 2013 Ben Lewis and David Donna *)
(* wound.ml, part of TexterQuest *)
(* LGPLv3 *)

include Util

type severity =
  | Glancing
  | Stun
  | Minor 
  | Middling
  | Critical
  | Mortal

(* severity and expiration *)
type wound = severity * int

type t = wound list ref

(* This will need to change *slightly* to accomodate the special nature of
   Glancing, Stun, and Mortal wounds. *)
let new_wound ?duration ?(discount=0) severity =
  let now = get_time () in
  let duration = match duration with
    | Some d -> d
    | None -> (match severity with
        (* default durations *)
        | Minor -> 60
        | Middling -> 120
        | Critical -> 360)
  in
  let expire = now + duration - discount in
  severity, expire

(* 
 * check whether a wound has healed; return a wound option representing the
 * current state of the wound (None if fully healed)
 *)
let rec check (severity, expire) =
  let now = get_time () in
  if expire > now then
    Some (severity, expire)
  else
    let discount = now - expire in
    match severity with
      | Minor -> None                   (* fully healed *)
      | Middling
      | Critical -> 
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
            check wound

let add_wound t ?duration ?discount severity =
  let wound = new_wound ?duration ?discount severity in
  wound >> t

let total_wounds t =
  let totals, remaining =
    List.fold_left
      (fun ((a, a', a''), remaining) wound ->
        (* find out whether wound has healed since last checked *)
        match check wound with
          | Some (severity, expires) ->
              (* increment the relevant counter, keep wound in list *)
              (match severity with
                | Minor      -> a + 1 , a'    , a''
                | Middling   -> a     , a' + 1, a''
                | Critical   -> a     , a'    , a'' + 1),
              (severity, expires)::remaining
          | None ->
              (* fully healed (discard from list) *)
              (a, a', a''), remaining)
      ((0,0,0), [])
      !t
  in
  t := remaining;
  totals

let create () = ref []
