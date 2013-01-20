(* Copyright (C) 2013 Ben Lewis and David Donna *)
(* server_util.ml, part of TexterQuest *)
(* LGPLv3 *)

(* Anything that include Server_util automatically includes Util. *)
include Util

type user_state =
  | Connected
  | CharSelect of username
  | LoggedIn   of username
