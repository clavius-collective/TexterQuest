(* Copyright (C) 2013 Ben Lewis and David Donna *)
(* mask.mli, part of TexterQuest *)
(* LGPLv3 *)

(** Provides a functor Make, which takes a module with a base type
    {!MASKABLE.t}, and returns a module with a record type {!MASKED.t}. This
    record carries masks, which are concrete representations of persistent
    effects and transformations.
    @author David Donna
*)

open Util
open Core
open Sexplib
open Sexplib.Std

(** Functionality required to make a maskable record. *)
module type MASKABLE = sig

  (** the type of the object on which masks will be acting (becomes
      {!MASKED.base} *)
  type t with sexp

  (** serializable type that can be interpreted to change a t *)
  type transform with sexp

  (** interpret a transform *)
  val apply_transform : t -> transform -> t

end

(** Collection of types and functions allowing a code object to be masked. Note
    that the type base exported by this module is equivalent to the type t.
 *)
module type MASKED = sig

  (** record storing a base value and a list of masks *)
  type t with sexp

  (** the {! MASKABLE.t} type from [M] *)
  type base

  (** the same as the transform type of the module acted on by the functor *)
  type transform

  (** serializable record representing a mask in its totality *)
  type mask with sexp

  (** list of branches *)
  type decay

  (** alters a function to operate on a mask-carrying record *)
  val on_base : (base -> 'a) -> t -> 'a

  (** Create a simple decay function that will leave a mask unchanged until the
      specified number of seconds has passed. At that point, the mask simply
      expires.
      
      Note that the duration is calculated from the moment the decay function
      is returned by this function. If you create several decay functions at
      once, e.g. to create a progressive transformation, they will all start
      aging at the same time. *)
  val expires_after : int -> decay

  (** Assemble the components of a mask, and apply them to a mask-bearing t. *)
  val add_mask :
    description : fstring   ->
    transform   : transform ->
    decay       : decay     ->
    t                       -> 
    unit

  (** Find the current value of a maskable object, by applying its masks. *)
  val get_value : t -> base

  (** Create a new [mask]-bearing record, with a starting [base] value. *)
  val create : base -> t
end

module Make : functor (M : MASKABLE) ->
  (MASKED with type base = M.t and type transform = M.transform)
