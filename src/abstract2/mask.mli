(* Copyright (C) 2013 Ben Lewis and David Donna *)
(* mask.mli, part of TexterQuest *)
(* LGPLv3 *)

(** Provides a functor Make, which takes a module with a base type
    MASKABLE.t, and returns a module with a record type T.t. This record
    carries masks, which are concrete representations of persistent effects and
    transformations.
*)

open Util
open Sexplib
open Sexplib.Std

(** Functionality required to make a maskable record. *)
module type MASKABLE = sig

  (** the type of the object on which masks will be acting *)
  type t
  val sexp_of_t : t -> Sexplib.Sexp.t
  val t_of_sexp : Sexplib.Sexp.t -> t

  (** serializable type that can be interpreted to change a t *)
  type transform
  val sexp_of_transform : transform -> Sexplib.Sexp.t
  val transform_of_sexp : Sexplib.Sexp.t -> transform

  (** interpret a transform *)
  val apply_transform : transform -> t -> t

end

(** Collection of types and functions allowing a code object to be masked. Note
    that the type base exported by this module is equivalent to the type t
 *)
module type T = sig

  (** record storing a base value and a list of masks *)
  type t
  val sexp_of_t : t -> Sexplib.Sexp.t
  val t_of_sexp : Sexplib.Sexp.t -> t

  (** the t type of the module to which the functor is applied *)
  type base

  (** the same as the transform type of the module acted on by the functor *)
  type transform

  (** serializable record representing a mask in its totality *)
  type mask
  val sexp_of_mask : mask -> Sexplib.Sexp.t
  val mask_of_sexp : Sexplib.Sexp.t -> mask

  (** Function that will return whatever form the mask has, or None if the mask
      has simply expired. An example would be a wound's decay function returning
      a less serious wound after it has healed for some time.
      
      The reason this takes a mask instead of unit is to allow de facto
      introspection. When a mask is checked for decay, it will be passed as the
      argument to its own decay function. Critically, this allows the decay
      function to return the mask itself, signifying no change. *)
  type decay = mask -> mask option

  (** alters a function to operate on a mask-carrying record *)
  val on_base : (base -> 'a) -> t -> 'a

  (** Create a simple decay function that will leave a mask unchanged until the
      specified number of seconds has passed. At that point, the mask simply
      expires. Using this as the first argument to a compose call, with the
      defer_none flag set, will suspend the other decay function for the same
      duration.
      
      Note that the duration is calculated from the moment the decay function is
      returned by this function. If you create several decay functions at once,
      e.g. to create a progressive transformation, they will all start aging at
      the same time. *)
  val expires_after : int -> decay

  (** Given two decay functions, return a decay function which starts by
      applying the first (decay) to the argument mask. If the defer_* flag
      corresponding to the return value is set to true, take the result (in the
      Some cases) or the original mask (in the None) case, and apply the second
      decay function (decay') to it, then return the result of that call.
      
      The defer flags are all false by default, indicating that decay' will not
      be applied at all unless one or more are manually set to true. *)
  val compose :
    ?defer_same   : bool ->
    ?defer_change : bool ->
    ?defer_none   : bool ->
    decay                ->
    decay                ->
    decay

  (** Assemble the components of a mask, and apply them to a mask-bearing t. *)
  val add_mask :
    description : fstring   ->
    transform   : transform ->
    decay       : decay     ->
    t                       -> 
    unit

  (** Find the current value of a maskable object, by applying its masks. *)
  val get_value : t -> base
end

module Make : functor (M : MASKABLE) ->
  (T with type base = M.t and type transform = M.transform)
