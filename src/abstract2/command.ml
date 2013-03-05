let get_command string =
  let buffer = Lexing.from_string string in
  Commandparse.get_command Commandlex.command buffer
