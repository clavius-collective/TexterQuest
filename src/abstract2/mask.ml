(* Copyright (C) 2013 Ben Lewis and David Donna *)
(* mask.ml, part of TexterQuest *)
(* LGPLv3 *)

include Util
include Core
include Sexplib
include Sexplib.Std

module type MASKABLE = sig
  type t with sexp
  type transform with sexp
    
  val apply_transform : t -> transform -> t
end

module type MASKED = sig
  type t with sexp
  type base
  type transform
  type mask with sexp
  type decay
      
  val on_base : (base -> 'a) -> t -> 'a
    
  val expires_after : int -> decay

  val add_mask :
    description : fstring   ->
    transform   : transform ->
    decay       : decay     ->
    ?tags       : tag list  ->
    t                       ->
    unit

  val get_value : t -> base

  val create : base -> t
end

module Make = functor (M : MASKABLE) -> (struct
  type base = M.t with sexp
  type transform = M.transform with sexp

  (* TODO: export this in the .mli *)
  type predicate =
    | Expires of int
    | And of predicate * predicate
    | Or of predicate * predicate
    | Always
    | Never
  with sexp

  type branch = {
    predicate : predicate;
    next      : mask option;
  }

  and decay = branch list

  and mask = {
    description : fstring;
    transform   : transform;
    decay       : decay;
    tags        : tag list;
  } with sexp

  type t = {
    base : base;
    mutable masks : mask list;
  } with sexp

  (* TODO: export this in the .mli *)
  let make_decay ?(next = None) ?(branches = []) predicate =
    {predicate; next}::branches

  (* lasts between n and n+1 seconds *)
  let expires_after duration =
    let expiration = int_time () + duration in
    make_decay (Expires expiration)

  let check_decay mask =
    let rec check_predicate = function
      | Expires time -> time < int_time ()
      | And (p, p')  -> check_predicate p && check_predicate p'
      | Or (p, p')   -> check_predicate p || check_predicate p'
      | Always       -> true
      | Never        -> false
    in
    let rec select_branch = function
      (* fold through the predicates by which the mask could decay *)
      | [] -> Some mask (* if no predicate matches, the mask is unchanged *)
      | branch::branches ->
          if check_predicate branch.predicate then
            branch.next
          else
            select_branch branches
    in
    select_branch mask.decay

  let on_base f x = f x.base

  let get_masks t = t.masks

  let set_masks t masks = t.masks <- masks

  let get_value t =
    let final_val, active =
      List.fold_right
        (fun mask (current, active) ->
          match check_decay mask with
            | None -> 
                current, active
            | Some mask ->
                M.apply_transform current mask.transform, mask::active)
        (get_masks t)
        (t.base, [])
    in
    set_masks t active;
    final_val

  let add_mask ~description ~transform ~decay ?(tags=[]) t =
    let mask =
      {
        description;
        transform;
        decay;
        tags
      }
    in
    set_masks t (mask::(get_masks t))

  let create base =
    {
      base = base;
      masks = [];
    }

  let describe mask = mask.description

end : MASKED with type base = M.t and type transform = M.transform)
