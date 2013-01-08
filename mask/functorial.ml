let get_time = Unix.time

type 'a mask = (('a -> 'a) * float)

module M = struct
  type t = {
    v : int;
    mutable masks : t mask list;
  }
      
  let create ?(masks=[]) v = { v; masks }
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
end;;

module F = Masked(M);;

let x = M.create 1 in
M.pr (F.see x);
F.mask x M.incr 3.;
M.pr (F.see x);
F.mask x M.incr 3.;
M.pr (F.see x);
F.mask x M.double 1.;
M.pr (F.see x);
Unix.sleep 2;
M.pr (F.see x);
Unix.sleep 2;
M.pr (F.see x)
