%{
  let printf s =
    Printf.bprintf (Buffer.create 100) s
    (* print_string "lexer: "; *)
    (* Printf.printf s *)

  let create = Action.make_command
%}

%token NEWLINE
%token DELIMIT
%token TARGET_START
%token TARGET_END
%token <string> WORD
%start get_command
%type <Action.command> get_command

%%

get_command:
  | command NEWLINE                        {$1}
;

command:
  | WORD args                              { create $1 (fst $2) (snd $2) }
;

args:
  |                                        { ([], []) }
  | list                                   { ($1, []) }
  | TARGET_START list                      { ([], $2) }
  | list TARGET_START list                 { ($1, $3) }
  | TARGET_START list TARGET_END list      { ($4, $2) }

list:
  | identifier                             { [$1] }
  | identifier DELIMIT list                { $1 :: $3 }
;

identifier:
  | WORD                                   { $1 }
  | WORD identifier                        { $1 ^ " " ^ $2 }

%%
(* trailer *)
