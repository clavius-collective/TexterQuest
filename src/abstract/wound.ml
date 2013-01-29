(* Copyright (C) 2013 Ben Lewis and David Donna *)
(* wound.ml, part of TexterQuest *)
(* LGPLv3 *)

include Util

type severity =
  | Minor 
  | Middling
  | Critical

module W = struct
  type acc = (int * int * int)
  type mask = acc Mask.mask
  type t = mask list ref

  let get_acc t = (0, 0, 0)
  let get_masks = (!)
  let set_masks t l = t := l
end

include W
module WoundMask = Mask.Mask(W)


let new_wound ?duration ?(discount=0) severity =
  let now = get_time () in
  let duration = match duration with
    | Some d -> d
    | None   -> (match severity with
          (* default durations *)
        | Minor    -> 60
        | Middling -> 120
        | Critical -> 360)
  in
  let expire = now + duration - discount in
  severity, expire

type severity_info = {
  adjective : string;
  duration  : int;
}
    
let info_of_severity = function
  | Minor    -> { adjective = "minor"    ; duration = 60  ; }
  | Middling -> { adjective = "middling" ; duration = 120 ; }
  | Critical -> { adjective = "critical" ; duration = 360 ; }


let transform severity (a, b, c) = match severity with
  | Minor    -> (a + 1, b, c)
  | Middling -> (a, b + 1, c)
  | Critical -> (a, b, c + 1)

let rec new_wound ?(delay = 0) severity =
  let info = info_of_severity severity in
  let description = info.adjective ^ " wound" in
  let transform = transform severity in
  let duration = info.duration + delay in
  let decay = WoundMask.compose
    ~defer_none:true
    (WoundMask.expires_after duration)
    (fun _ -> match severity with
      | Minor -> None
      | Middling -> Some (new_wound ~delay:duration Minor)
      | Critical -> Some (new_wound ~delay:duration Middling))
  in
  WoundMask.create ~description ~transform ~decay

let add_wound t ?delay severity =
  let wound = new_wound ?delay severity in
  WoundMask.add_mask t wound

let total_wounds = WoundMask.get_value

let create () = ref []
