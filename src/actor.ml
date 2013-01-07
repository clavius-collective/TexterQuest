include Types

type t = {
  name : string;
  mutable location : room_id;
}

let create name location = {
  name;
  location;
}

let get_name a = a.name
let get_loc a = a.location
let set_loc a r = a.location <- r
