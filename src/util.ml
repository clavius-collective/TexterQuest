let generate (f : int -> 'a) : unit -> 'a =
  let _counter = ref 0 in
  fun () ->
    incr _counter;
    f !_counter
