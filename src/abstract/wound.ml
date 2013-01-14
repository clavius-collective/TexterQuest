(* Copyright (C) 2013 Ben Lewis and David Donna *)
(* wound.ml, part of TexterQuest *)
(* LGPLv3 *)

type severity =
  | Minor 
  | Middling
  | Mortifying

type t = (severity * int) list ref

let new_wound ?duration severity =
  let time = Util.get_time () in
  let duration = match duration with
    | Some d -> d
    | None   -> (match severity with
        | Minor      -> 30
        | Middling   -> 90
        | Mortifying -> 270)
  in
  severity, time + duration

let check (severity, expire) =
  if expire > Util.get_time () then
    Some (severity, expire)
  else
    match severity with
      | Minor      -> None
      | Middling   -> Some (new_wound Minor)
      | Mortifying -> Some (new_wound Middling)

let add_wound t ?duration severity =
  t := (new_wound ?duration severity)::!t

let total_wounds t =
  let totals, remaining =
    List.fold_left
      (fun ((a, a', a''), remaining) wound ->
        match check wound with
          | Some (severity, expires) -> 
              (match severity with
                | Minor      -> a + 1, a', a''
                | Middling   -> a, a' + 1, a''
                | Mortifying -> a, a', a'' + 1),
              (severity, expires)::remaining
          | None ->
              (a, a', a''), remaining)
      ((0,0,0), [])
      !t
  in
  t := remaining;
  totals

let create () = ref []
