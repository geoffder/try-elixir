# We've already used maps %{}, examples below:

map = %{a: 1, b: 2}
IO.puts inspect(map)
IO.puts "map[:a] -> "<> inspect(map[:a])

map = %{map | a: 3}  # use pattern match to update value of :a
IO.puts inspect(map)
IO.puts ""

# From elixir-lang getting-started:
# Structs are extensions built on top of maps that provide compile-time checks
# and default values.

# defined in struct_User.ex (must be compiled)
# defmodule User do
#   defstruct name: "Geoff", age: 30
# end

# Structs take the name of the module they're defined in.
IO.puts inspect(%User{})
new_user = %User{name: "Jane"}  # age uses default value
IO.puts inspect(new_user)

# Structs provide compile-time guarantees that only the fields (and all of
# them) defined through defstruct will be allowed to exist in a struct:
# spawn fn -> %User{oops: :field} end
# looks like trying to do this even in another process crashes my shell...

# we can read and update the values of fields in Structs much like with maps
geoff = %User{}
IO.puts "geoff's age is: " <> inspect(geoff.age)

jane = %{geoff | name: "Jane", age: 23}
IO.puts inspect(jane)

steve = Map.put(%User{}, :name, "Steve")
IO.puts inspect(steve)

# This works because Structs are bare maps underneath, but with a fixed set of
# fields. They also have a special field that stores the name of the Struct.
IO.puts "geoff is an instance of the Struct -> #{inspect geoff.__struct__}"
IO.puts "Map.keys(geoff) -> " <> inspect(Map.keys(geoff))
