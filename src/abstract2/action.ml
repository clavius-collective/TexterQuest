include Sexplib
include Sexplib.Std

type command = {
  cmd     : string;
  args    : string list;
  targets : string list;
} with sexp

let make_command cmd args targets = { cmd; args; targets; }
