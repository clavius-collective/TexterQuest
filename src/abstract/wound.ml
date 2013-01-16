(* Copyright (C) 2013 Ben Lewis and David Donna *)
(* wound.ml, part of TexterQuest *)
(* LGPLv3 *)

include Util

type severity =
  | Minor 
  | Middling
  | Mortifying

type t = (severity * int) list ref

let new_wound ?duration ?(discount=0) severity =
  let now = get_time () in
  let duration = match duration with
    | Some d -> d
    | None -> (match severity with
        | Minor -> 60
        | Middling -> 120
        | Mortifying -> 360)
  in
  let expire = now + duration - discount in
  severity, expire

let rec check (severity, expire) =
  let now = get_time () in
  if expire > now then
    Some (severity, expire)
  else
    let discount = now - expire in
    match severity with
      | Minor -> None
      | Middling
      | Mortifying -> 
          let new_severity = (match severity with
            | Minor -> failwith "sanity check failed"
            | Middling -> Minor
            | Mortifying -> Middling)
          in
          let (_, new_expire) as wound = (new_wound ~discount new_severity) in
          if new_expire < now then
            check wound
          else
            Some wound

let add_wound t ?duration ?discount severity =
  new_wound ?duration ?discount severity >> t

let total_wounds t =
  let totals, remaining =
    List.fold_left
      (fun ((a, a', a''), remaining) wound ->
        match check wound with
          | Some (severity, expires) -> 
              (match severity with
                | Minor      -> a + 1 , a'    , a''
                | Middling   -> a     , a' + 1, a''
                | Mortifying -> a     , a'    , a'' + 1),
              (severity, expires)::remaining
          | None ->
              (a, a', a''), remaining)
      ((0,0,0), [])
      !t
  in
  t := remaining;
  totals

let create () = ref []
