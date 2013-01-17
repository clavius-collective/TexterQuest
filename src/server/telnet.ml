(* Copyright (C) 2013 Ben Lewis and David Donna *)
(* telnet.ml, part of TexterQuest *)
(* LGPLv3 *)

(* This produces an executable that will run a telnet server for the game. *)

include Util
include Unix

type client = file_descr

let prompt = ">>>"

let users = Hashtbl.create 100
let clients = ref []

let send_output sock s =
  let rec send_part = function
    | Raw s ->
        ignore (send sock s 0 (String.length s) [])
    | Bold s | Italic s | Underline s | Color (_, s) ->
        send_part s
    | Sections fstrings ->
        let rec send_sections = function
          | [] -> ()
          | [x] -> send_part x
          | x::xs ->
              send_part (Concat [x; Raw "\n\n"]);
              send_sections xs
        in
        send_sections fstrings
    | Concat fstrings ->
        List.iter send_part fstrings
  in
  send_part s;
  send_part (Raw ("\n" ^ prompt ^ " "))

let lookup = Hashtbl.find users

let get_player sock = match lookup sock with
  | CharSelect player 
  | LoggedIn player -> Some player
  | Connected -> None

let disconnect sock =
  let name = match get_player sock with
    | Some player -> player
    | None -> "a user"
  in
  debug (name ^ " disconnected");
  Hashtbl.remove users sock;
  clients := remove sock !clients;
  shutdown sock SHUTDOWN_ALL

let check_login input =
  let player = input in
  Some player

let process_input sock input =
  if matches_ignore_case "quit" input or input.[0] = Char.chr 4 then
    disconnect sock
  else
    match lookup sock with
      | Connected ->
          (match check_login input with
            | Some player ->
                debug (player ^ " logged in");
                Hashtbl.replace users sock (CharSelect player);
                send_output sock (Game.player_login player)
            | None -> 
                send_output sock (Raw "Invalid username, please try again."))
      | CharSelect player ->
          Hashtbl.replace users sock (LoggedIn player);
          let send = (send_output sock) in
          Game.player_select_character send player 0
      | LoggedIn player -> 
          Game.process_input player input

let start () =
  Room.create "start" "the starting zone" [|"other", "another room"|];
  Room.create "other" "the other room" [|"start", "the first room"|];

  let server =
    let server_sock = socket PF_INET SOCK_STREAM 0 in
    setsockopt server_sock SO_REUSEADDR true;
    let address = (gethostbyname (gethostname ())).h_addr_list.(0) in
    bind server_sock (ADDR_INET (address, 1029));
    listen server_sock 10;
    server_sock
  in

  let accept_client () =
    let sock, addr = accept server in
    sock >> clients;
    Hashtbl.add users sock Connected;
    send_output sock (Raw "\nTEXTER QUEST\n\nPlease enter username")
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
    let input, _, exceptions = select (server::!clients) [] [] (-1.0) in
    List.iter handle input;
    List.iter disconnect exceptions
  done
