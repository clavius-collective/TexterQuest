(* supply a counter that will be incremented each time f is called *)
val generate : (int -> 'a -> 'b) -> 'a -> 'b

(* given a string "foo", supply a stream of "foo_1", "foo_2", etc. *)
val generate_str : string -> (string -> 'a -> 'b) -> 'a -> 'b

(* right-associative application function (like Haskell's $ operator) *)
val (@@) : ('a -> 'b) -> 'a -> 'b
