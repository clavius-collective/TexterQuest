type room_id = string

type username = string

type fstring =
  | Raw of string
  | Bold of fstring
  | Italic of fstring
  | Underline of fstring
  | Color of int * fstring
  | Concat of fstring * fstring
  | Sections of fstring list
  | List of fstring list

type user_state =
  | Connected
  | CharSelect of username
  | LoggedIn of username
