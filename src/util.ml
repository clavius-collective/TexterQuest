let generate f =
  let _counter = ref 0 in
  fun x ->
    incr _counter;
    f !_counter x

let generate_str base f =
  let foo i = base ^ "_" ^ (string_of_int i) in
  generate (fun i x -> f (foo i) x)

let (@@) f x = f x
