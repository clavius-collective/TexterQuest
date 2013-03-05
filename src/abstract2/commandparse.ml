type token =
  | NEWLINE
  | DELIMIT
  | TARGET_START
  | TARGET_END
  | WORD of (string)

open Parsing;;
# 2 "commandparse.mly"
  let printf s =
    Printf.bprintf (Buffer.create 100) s
    (* print_string "lexer: "; *)
    (* Printf.printf s *)

  let create = Action.make_command
# 17 "commandparse.ml"
let yytransl_const = [|
  257 (* NEWLINE *);
  258 (* DELIMIT *);
  259 (* TARGET_START *);
  260 (* TARGET_END *);
    0|]

let yytransl_block = [|
  261 (* WORD *);
    0|]

let yylhs = "\255\255\
\001\000\002\000\003\000\003\000\003\000\003\000\003\000\004\000\
\004\000\005\000\005\000\000\000"

let yylen = "\002\000\
\002\000\002\000\000\000\001\000\002\000\003\000\004\000\001\000\
\003\000\001\000\002\000\002\000"

let yydefred = "\000\000\
\000\000\000\000\000\000\012\000\000\000\000\000\000\000\002\000\
\000\000\000\000\001\000\000\000\011\000\000\000\000\000\000\000\
\006\000\009\000\007\000"

let yydgoto = "\002\000\
\004\000\005\000\008\000\009\000\010\000"

let yysindex = "\005\000\
\007\255\000\000\002\255\000\000\014\255\011\255\011\255\000\000\
\015\255\017\255\000\000\013\255\000\000\011\255\011\255\011\255\
\000\000\000\000\000\000"

let yyrindex = "\000\000\
\000\000\000\000\019\255\000\000\000\000\000\000\000\255\000\000\
\020\255\010\255\000\000\021\255\000\000\000\000\000\000\000\000\
\000\000\000\000\000\000"

let yygindex = "\000\000\
\000\000\000\000\000\000\250\255\016\000"

let yytablesize = 23
let yytable = "\012\000\
\010\000\010\000\010\000\010\000\006\000\001\000\007\000\017\000\
\018\000\019\000\008\000\003\000\008\000\008\000\011\000\007\000\
\016\000\014\000\015\000\003\000\004\000\005\000\013\000"

let yycheck = "\006\000\
\001\001\002\001\003\001\004\001\003\001\001\000\005\001\014\000\
\015\000\016\000\001\001\005\001\003\001\004\001\001\001\005\001\
\004\001\003\001\002\001\001\001\001\001\001\001\007\000"

let yynames_const = "\
  NEWLINE\000\
  DELIMIT\000\
  TARGET_START\000\
  TARGET_END\000\
  "

let yynames_block = "\
  WORD\000\
  "

let yyact = [|
  (fun _ -> failwith "parser")
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 1 : 'command) in
    Obj.repr(
# 21 "commandparse.mly"
                                           (_1)
# 87 "commandparse.ml"
               : Action.command))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 1 : string) in
    let _2 = (Parsing.peek_val __caml_parser_env 0 : 'args) in
    Obj.repr(
# 25 "commandparse.mly"
                                           ( create _1 (fst _2) (snd _2) )
# 95 "commandparse.ml"
               : 'command))
; (fun __caml_parser_env ->
    Obj.repr(
# 29 "commandparse.mly"
                                           ( ([], []) )
# 101 "commandparse.ml"
               : 'args))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 0 : 'list) in
    Obj.repr(
# 30 "commandparse.mly"
                                           ( (_1, []) )
# 108 "commandparse.ml"
               : 'args))
; (fun __caml_parser_env ->
    let _2 = (Parsing.peek_val __caml_parser_env 0 : 'list) in
    Obj.repr(
# 31 "commandparse.mly"
                                           ( ([], _2) )
# 115 "commandparse.ml"
               : 'args))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 2 : 'list) in
    let _3 = (Parsing.peek_val __caml_parser_env 0 : 'list) in
    Obj.repr(
# 32 "commandparse.mly"
                                           ( (_1, _3) )
# 123 "commandparse.ml"
               : 'args))
; (fun __caml_parser_env ->
    let _2 = (Parsing.peek_val __caml_parser_env 2 : 'list) in
    let _4 = (Parsing.peek_val __caml_parser_env 0 : 'list) in
    Obj.repr(
# 33 "commandparse.mly"
                                           ( (_4, _2) )
# 131 "commandparse.ml"
               : 'args))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 0 : 'identifier) in
    Obj.repr(
# 36 "commandparse.mly"
                                           ( [_1] )
# 138 "commandparse.ml"
               : 'list))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 2 : 'identifier) in
    let _3 = (Parsing.peek_val __caml_parser_env 0 : 'list) in
    Obj.repr(
# 37 "commandparse.mly"
                                           ( _1 :: _3 )
# 146 "commandparse.ml"
               : 'list))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 0 : string) in
    Obj.repr(
# 41 "commandparse.mly"
                                           ( _1 )
# 153 "commandparse.ml"
               : 'identifier))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 1 : string) in
    let _2 = (Parsing.peek_val __caml_parser_env 0 : 'identifier) in
    Obj.repr(
# 42 "commandparse.mly"
                                           ( _1 ^ " " ^ _2 )
# 161 "commandparse.ml"
               : 'identifier))
(* Entry get_command *)
; (fun __caml_parser_env -> raise (Parsing.YYexit (Parsing.peek_val __caml_parser_env 0)))
|]
let yytables =
  { Parsing.actions=yyact;
    Parsing.transl_const=yytransl_const;
    Parsing.transl_block=yytransl_block;
    Parsing.lhs=yylhs;
    Parsing.len=yylen;
    Parsing.defred=yydefred;
    Parsing.dgoto=yydgoto;
    Parsing.sindex=yysindex;
    Parsing.rindex=yyrindex;
    Parsing.gindex=yygindex;
    Parsing.tablesize=yytablesize;
    Parsing.table=yytable;
    Parsing.check=yycheck;
    Parsing.error_function=parse_error;
    Parsing.names_const=yynames_const;
    Parsing.names_block=yynames_block }
let get_command (lexfun : Lexing.lexbuf -> token) (lexbuf : Lexing.lexbuf) =
   (Parsing.yyparse yytables 1 lexfun lexbuf : Action.command)
;;
# 45 "commandparse.mly"
(* trailer *)
# 188 "commandparse.ml"
