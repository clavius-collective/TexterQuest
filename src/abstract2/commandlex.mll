{
  open Lexing
  open Commandparse

  let printf s =
    Printf.bprintf (Buffer.create 100) s
    (* print_string "lexer: "; *)
    (* Printf.printf s *)
}

let target_start = '>'
let target_end = ':'
let delimit = ','|';'
let word = [^'>'':'','';'' ''\n''\r''\t']+
let words = (word ' ')*word
let endline = ['\r''\n']+
let whitespace = [' ''\t']
let string = ('\\'_|[^'"'])*

rule command = parse
| delimit
  { printf "COMMA\n";
    DELIMIT }
| '"' (string as s) '"'
  { printf "WORD %s\n" s;
    WORD s }
| target_start
  { printf "TARGET_START\n";
    TARGET_START } 
| word as id
  { printf "WORD %s\n" id;
    WORD id }
| target_end
  { printf "TARGET_END\n";
    TARGET_END } 
| endline
  { printf "NEWLINE\n";
    NEWLINE }
| eof { raise End_of_file }
| whitespace
  { command lexbuf }
| _
  { command lexbuf }

{
let get_command string = 
  let buffer = Lexing.from_string string in
  Commandparse.get_command command buffer
}
