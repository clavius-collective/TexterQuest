include Util

type id =
  | IdFoo
  | IdBar

type t =
  | TFoo of Foo.t
  | TBar of Bar.t

type mask =
  | MaskFoo of Foo.mask
  | MaskBar of Bar.mask

let id_of_t = function
  | TFoo _ -> IdFoo
  | TBar _ -> IdBar

let id_of_mask = function
  | MaskFoo _ -> IdFoo
  | MaskBar _ -> IdBar

let create = function
  | IdFoo -> Foo.create
  | IdBar -> Bar.create

let apply' = function
  | MaskFoo m -> (function TFoo t -> Foo.add_mask t mask | _ -> ())
  | MaskBar m -> (function TBar t -> Bar.add_mask t mask | _ -> ())

let create_foo t = TFoo t
let create_foo_mask mask = MaskFoo mask

let create_bar t = TBar t
let create_bar_mask mask = MaskBar mask

let matches mask t = (id_of t t) = (id_of_mask mask)
let supports mask = List.exists (fun t -> matches mask)
let apply mask = List.iter (apply' mask)
let supports_all masks vec = List.for_all (supports mask vec) masks
