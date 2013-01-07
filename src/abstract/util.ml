let generate (f : int -> 'a) : 'a =
  let _counter = ref 0 in
  fun x ->
    incr _counter;
    f !_counter x

let generate_str s (f : string -> 'a) : 'a =
  (* generate (fun i x -> (f (s ^ "_" ^ (string_of_int i)) x)) *)

  (* let _counter = ref 0 in *)
  let foo i = s ^ "_" ^ (string_of_int i) in
  (* fun x -> *)
  (*   incr _counter; *)
  (*   f (foo !_counter) x *)

  generate (fun i x -> f (foo i) x)
