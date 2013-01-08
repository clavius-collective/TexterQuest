let generate f =
  let _counter = ref 0 in
  fun x ->
    incr _counter;
    f !_counter x

let generate_str s f =
  let new_string i = s ^ "_" ^ (string_of_int i) in
  generate (fun i x -> f (new_string i) x)

let (@@) f x = f x
