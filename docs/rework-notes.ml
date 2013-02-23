(* hook.ml *)
type role = Acting | Present (* | ... *)
type meta_context            (* described modification of context *)
type meta_effect             (* described modification of effect *)
type t =
  | AHook of ((context * role) -> meta_context)
  | EHook of (effect * role) -> meta_effect

(* aspect.ml *)
type affinities = (core_aspect * float) list
val core_affinities : (t * float) list -> affinities

(* masked.ml -- aggregator for maskable things *)
(* GENERATE PROGRAMMATICALLY FROM FLAT FILE *)
type t = Wound of MWound.t (* | ... *)
type mask = WoundMask of MWound.mask (* | ... *)
type id = TWound (* | ... *)
let id_of_mask = function WoundMask _ -> TWound (* | ... *)
let create = function TWound -> TWound, Wound MWound.create () (* | ... *)

(* object.ml -- vector of whosises *)
type t = (Masked.id * Masked.t) list  (* with mask *)
type template = unit -> t
type mask = obj Mask.mask
val mask : t -> Masked.mask -> unit     (* mask specific axis *)
val transform : t -> mask -> unit       (* mask object itself *)
let update l1 l2 =
  let rec update' l1 l2 = match l1, l2 with
    | h::t, h'::t' ->
        let x = compare (fst h) (fst h') in
        if      x = 0 then h'::(update' t      t'      )
        else if x < 0 then h ::(update' t      (h'::t'))
        else (* x > 0 *)   h'::(update' (h::t) t'      )
    | _, _ -> l1 @ l2
  in
  update' l1 l2
let rec update l = function
  | [] -> l
  | x::xs -> update x::(List.remove_assoc x l) xs
let base_object () =
  let open Masked in
  create [
    THook;                              (* enable hooks *)
    TAspect;                            (* enable aspect affinities *)
  ]
val create : ?base:template -> (Masked.id list) -> template
let create ?(base = base_object ()) template =
  update base (List.map Masked.create template)
let instantiate = List.map (fun template -> template ())

(* actor.ml -- is a type of object *)
type t           (* possibly hide Object.t equality ... probably not*)
let create = Object.create [Masked.TAgency; Masked.TPerception]
let create_creature = Object.create ~base:(create ()) [Masked.TWound]

(* room.ml -- locativity! *)
val aspects : t -> Aspect.affinities    (* lift from things *)

(* context.ml -- for actions *)
type t = {
  room : Room.t;
  acting : Object.t;
  targets : Object.t list;
  description : fstring;
}
val get_hooks : t -> Hook.t list
val process_context : t -> t

(* effect.ml -- yerp *)
type effect
type t = {
  room : Room.t;
  acting : Object.t;
  targets : Object.t list;
  effect : effect;
  consequences : effect list;
  description : fstring;
}
val get_hooks : t - > Hook.t list
val process_effect : t -> t
