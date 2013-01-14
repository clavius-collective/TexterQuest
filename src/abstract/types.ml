(* Copyright (C) 2013 Ben Lewis and David Donna *)
(* types.ml, part of TexterQuest *)
(* LGPLv3 *)

type 'a mask = ('a -> 'a) * int

(* fundamental data types *)
type room_id = string

type username = string

type user_state =
  | Connected
  | CharSelect of username
  | LoggedIn   of username

(* formatted output *)
type color = int

type fstring =
  | Raw        of string
  | Bold       of fstring
  | Italic     of fstring
  | Underline  of fstring
  | Color      of color * fstring
  | Sections   of fstring list
  | Concat     of fstring list
