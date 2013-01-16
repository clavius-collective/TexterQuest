type t = bool ref

let create () = ref false

let lock t =
  while !t do () done;
  t := true

let try_lock t = 
  if not !t then
    (t := true; true)
  else
    false

let unlock t = t := false
