open Command
open OUnit
open Printf
open Action

let print c = print_endline (Sexplib.Sexp.to_string (sexp_of_command c))
let to_s c = Sexplib.Sexp.to_string (sexp_of_command c)

let cmd1 () =
  let cmd1 = get_command "cmd\n" in
  let cmd1' = Action.make_command "cmd" [] [] in
  assert_equal cmd1 cmd1'

let cmd2 () =
  let cmd2 = get_command "cmd arg1, arg2\n" in
  let cmd2' = Action.make_command "cmd" ["arg1"; "arg2"] [] in
  assert_equal cmd2 cmd2'

let cmd3 () =
  let cmd3 = get_command "cmd >target1, target2\n" in
  let cmd3' = Action.make_command "cmd" [] ["target1"; "target2"] in
  assert_equal cmd3 cmd3'

let cmd4 () =
  let cmd4 = get_command "cmd arg1,arg2 >target1, target2\n" in
  let cmd4' =
    Action.make_command "cmd" ["arg1"; "arg2"] ["target1"; "target2"]
  in
  assert_equal cmd4 cmd4'

let cmd5 () =
  let cmd5 = get_command "cmd >target1, target2: arg1,arg2\n" in
  let cmd5' =
    Action.make_command "cmd" ["arg1"; "arg2"] ["target1"; "target2"]
  in
  assert_equal cmd5 cmd5'

let equals s s' () =
  assert_equal (get_command (s ^ "\n")) (get_command (s' ^ "\n"))

let not_equals s s' () =
  let c = get_command (s ^ "\n") in
  let c' = get_command (s' ^ "\n") in
  assert_bool ((to_s c) ^ " " ^ (to_s c')) (c <> c')

let tests = [
  "cmd1", cmd1;
  "cmd2", cmd2;
  "cmd3", cmd3;
  "cmd4", cmd4;
  "cmd5", cmd5;
  "str/id", equals "say \"hello\"" "say hello";
  "long identifier", equals "say \"hello there\"" "say hello there";
]
