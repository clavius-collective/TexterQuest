(* Copyright (C) 2013 Ben Lewis and David Donna *)
(* Licensed under LGPLv3 *)

(* This produces an executable that will run a telnet server for the game. *)

include Types
include Unix

type user = file_descr

let no_debug = ref false
let debug s = if not !no_debug then print_endline (">> " ^ s)

let users = Hashtbl.create 100
let clients = ref []

let new_user = Util.generate_str "user"

let send_output sock s =
  let rec send_part = function
    | Raw s ->
        ignore (send sock s 0 (String.length s) [])
    | Bold s | Italic s | Underline s | Color (_, s) ->
        send_part s
    | Sections fstrings ->
        List.iter
          (fun s -> send_part (Concat (s, Raw "\n\n")))
          fstrings
    | List fstrings ->
        List.iter
          (fun s ->
            send_part (Concat (Raw "* ", Concat (s, Raw "\n"))))
          fstrings
    | Concat (s1, s2) ->
        send_part s1;
        send_part s2
  in
  send_part s;
  send_part (Raw "\n")

let disconnect sock =
  debug ((Hashtbl.find users sock) ^ " disconnected");
  Hashtbl.remove users sock;
  clients := Util.remove sock !clients;
  shutdown sock SHUTDOWN_ALL

let process_input sock input =
  if Util.matches_ignore_case "quit" input then
    disconnect sock
  else
    let output = Game.process_input (Hashtbl.find users sock) input in
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
    let player = new_user () in
    Hashtbl.add users sock player;
    List.iter (send_output sock) [
      Raw "TEXTER QUEST\n";
      Game.player_login player
    ]
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
