(* Copyright (C) 2013 Ben Lewis and David Donna *)
(* main.ml, part of TexterQuest *)
(* LGPLv3 *)

include Util

let _ =
  Arg.parse
    [
      "-q", Arg.Set no_debug, "quiet mode"
    ] (fun _ -> ()) "TelnetsterQuest!";
  Mutator.start ();
  Combat.start ();
  Telnet.start ()
