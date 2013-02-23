(* Copyright (C) 2013 Ben Lewis and David Donna *)
(* core.mli, part of TexterQuest *)
(* LGPLv3 *)

(** Essential types, values, and functionality for TexterQuest.
    @author David Donna *)

(** Because rooms may be written to a database when unoccupied, they are most
    commonly referred to by a corresponding ID. This also corresponds to the 
    name/path/key (as yet unknown) of the file containing the room's
    specification. *)
type room_id = string

(** Uniquely identifies a player, as distinct from a player character. *)
type username = string

(** Text color (see {!modifier}) *)
type color = int

(** Text formatting options used in {!fstring} *)
type modifier =
  | Bold
  | Italic
  | Underline
  | Color of color
with sexp

(** Represents formatted text, which is output to the user. Because different
    potential server interfaces can have different priorities (readability vs 
    small messages vs fewer newlines), the actual formatting is abstract. *)
type fstring =
  | Raw       of string
  | Modified  of modifier * fstring
  | Sections  of fstring list
  | Concat    of fstring list
with sexp

(** Very generic tag used to mark certain properties of masks, objects,
    effects, or anything else that can have properties. In practical terms,
    tags can be used in predicates, for example, when examining an object for
    ongoing magical effects. *)
type tag

(** the size of the hash tables storing information *)
val hash_size : int
