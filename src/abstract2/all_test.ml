open OUnit

let test_pass () = assert_equal true true
let test_fail () = assert_equal true false

let add_tests (modname, lst) =
  List.map (fun (name, test) -> (modname ^ "_" ^ name) >:: test) lst

let suite = "Test" >::: List.flatten (List.map add_tests [
  "util"    , Util_test.tests;
  "core"    , Core_test.tests;
  "mask"    , Mask_test.tests;
  "command" , Command_test.tests;
])

let _ =
  run_test_tt_main suite
