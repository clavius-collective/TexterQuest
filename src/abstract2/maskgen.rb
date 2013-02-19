path = 'modules.lst'
$modules = File.readlines(path).map {|s| s.chomp}
$output = File.open 'masked.ml', 'w'

$output << "include Util\n\n"

def make_alternator (header)
  $output << header + $modules.map do |m|
    "\n  | " + (yield m.capitalize)
  end.join + "\n\n"
end

def make_type (name, &b) make_alternator("type #{name} =", &b) end
def make_function (name, &b) make_alternator("let #{name} = function", &b) end

def id (m) "Id" + m.capitalize end
def mask (m) "Mask" + m.capitalize end
def t (m) "T" + m.capitalize end

make_type('id') {|m| id m}
make_type('t') {|m| "#{t m} of #{m}.t"}
make_type('mask') {|m| "#{mask m} of #{m}.mask"}
make_function('id_of_t') {|m| "#{t m} _ -> #{id m}"}
make_function('id_of_mask') {|m| "#{mask m} _ -> #{id m}"}
make_function('create') {|m| "#{id m} -> #{m}.create"}
make_function('apply\'') do |m|
  "#{mask m} m -> (function " +
    "#{t m} t -> #{m}.add_mask t mask " +
    "| _ -> ())"
end

$modules.each do |m|
  $output << "let create_#{m} t = #{t m} t\n"
  $output << "let create_#{m}_mask mask = #{mask m} mask\n\n"
end

$output << <<-ADDITIONAL
let matches mask t = (id_of t t) = (id_of_mask mask)
let supports mask = List.exists (fun t -> matches mask)
let apply mask = List.iter (apply' mask)
let supports_all masks vec = List.for_all (supports mask vec) masks
ADDITIONAL

$output.close()
