let get_time = Unix.time

type 'a mask = (('a -> 'a) * float)

module M = struct
  type t = {
    v : int;
    mutable masks : t mask list;
  }
      
  let create ?(masks = []) v = { v; masks }
  let pr x = print_endline (string_of_int x.v)
    
  let incr x = { x with v = x.v + 1 }
  let decr x = { x with v = x.v - 1 }
  let double x = { x with v = 2 * x.v }
  
  let get_masks t = t.masks
  let set_masks t masks = t.masks <- masks
end

module Masked = functor (Obj : sig
  type t
  val get_masks : t -> t mask list
  val set_masks : t -> t mask list -> unit
end) -> struct
  let mask x func duration =
    M.set_masks x ((func, get_time () +. duration)::(M.get_masks x))
      
  let see x =
    let time = get_time () in
    let masked, masks =
      List.fold_right
        (fun ((func, expire) as mask) (current, active) ->
          if expire > time then
            func(current), mask::active
          else
            current, active)
        (Obj.get_masks x)
        (x, [])
    in
    Obj.set_masks x masks;
    masked      
end

module F = Masked(M);;

let _ =
  let x = M.create 1 in
  M.pr (F.see x);                         (* 1 *)
  F.mask x M.incr 2.;
  M.pr (F.see x);                         (* 1 + 1 = 2 *)
  F.mask x M.incr 2.;
  M.pr (F.see x);                         (* 1 + (1 + 1) = 3 *)
  F.mask x M.double 1.;
  M.pr (F.see x);                         (* 2 * (1 + (1 + 1)) = 6 *)
  Unix.sleep 1;
  M.pr (F.see x);                         (* the double expires (3) *)
  Unix.sleep 1;
  M.pr (F.see x)                          (* the incrs expire (1) *)
