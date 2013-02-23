(* Copyright (C) 2013 Ben Lewis and David Donna *)
(* core.mli, part of TexterQuest *)
(* LGPLv3 *)

(* fundamental data types *)
type room_id = string

type username = string

(* formatted output *)
type color = int

type modifier =
  | Bold
  | Italic
  | Underline
  | Color of color
with sexp

type fstring =
  | Raw       of string
  | Modified  of modifier * fstring
  | Sections  of fstring list
  | Concat    of fstring list
with sexp

type tag