(* Copyright (C) 2013 Ben Lewis and David Donna *)
(* telnet.ml, part of TexterQuest *)
(* LGPLv3 *)

(* This produces an executable that will run a telnet server for the game. *)

include Types
include Unix

type client = file_descr

let no_debug = ref false
let debug s = if not !no_debug then print_endline (">> " ^ s)

let users = Hashtbl.create 100
let clients = ref []

let new_user =
  let generator = Util.generate_str "user" in
  generator

let send_output ?(newline=1) sock s =
  let rec send_part = function
    | Raw s ->
        ignore (send sock s 0 (String.length s) [])
    | Bold s | Italic s | Underline s | Color (_, s) ->
        send_part s
    | Sections fstrings ->
        List.iter
          (fun s -> send_part (Concat [s; Raw "\n\n"]))
          fstrings
    | Concat fstrings ->
        List.iter
          (fun s ->
            send_part (Concat [Raw "* "; s; Raw "\n"]))
          fstrings
  in
  send_part s;
  for i = 1 to newline do send_part (Raw "\n") done

let lookup = Hashtbl.find users

let get_player sock = match lookup sock with
  | CharSelect player | LoggedIn player -> Some player
  | Connected -> None

let disconnect sock =
  let name = match get_player sock with
    | Some player -> player
    | None -> "a user"
  in
  debug (name ^ " disconnected");
  Hashtbl.remove users sock;
  clients := Util.remove sock !clients;
  shutdown sock SHUTDOWN_ALL

let check_login input =
  let player = input in
  Some player

let process_input sock input =
  if Util.matches_ignore_case "quit" input then
    disconnect sock
  else
    match lookup sock with
      | Connected ->
          (match check_login input with
            | Some player ->
                Hashtbl.replace users sock (CharSelect player);
                send_output ~newline:0 sock (Game.player_login player)
            | None -> 
                send_output sock (Raw "Invalid username, please try again."))
      | CharSelect player -> 
          send_output sock (Raw "Fuck dat shit, you're in.\n");
          Hashtbl.replace users sock (LoggedIn player);
          send_output sock (Game.player_select_character player 0)
      | LoggedIn player -> 
          let output = Game.process_input player input in
          send_output sock output

let start () =

  Room.create "start" "the starting zone" [|"other", "another room"|];
  Room.create "other" "the other room" [|"start", "the first room"|];

  let server =
    let server_sock = socket PF_INET SOCK_STREAM 0 in
    setsockopt server_sock SO_REUSEADDR true;
    let address = (gethostbyname(gethostname ())).h_addr_list.(0) in
    bind server_sock (ADDR_INET (address, 1029));
    listen server_sock 10;
    server_sock
  in

  let accept_client () =
    let (sock, addr) = accept server in
    clients := sock :: !clients;
    Hashtbl.add users sock Connected;
    send_output ~newline:0 sock (Raw "TEXTER QUEST\n\nPlease enter username: ")
  in

  let handle sock =
    let max_len = 1024 in
    if sock = server then
      accept_client ()
    else
      let buffer = String.create max_len in
      let len = recv sock buffer 0 max_len [] in
      if len = 0 then
        disconnect sock
      else
        let input = String.sub buffer 0 len in
        let endline = Str.regexp "\r?\n\r?" in
        List.iter (process_input sock) (Str.split endline input)
  in

  while true do
    let input, _, _ = select (server::!clients) [] [] (-1.0) in
    List.iter handle input
  done

let _ =
  Arg.parse
    [
      "-q", Arg.Set no_debug, "verbose mode"
    ] (fun _ -> ()) "basic MUD";
  start ()
