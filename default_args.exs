defmodule Concat do
  # \\ after an argument in definition denotes a default value
  # this means that sep will not be involved in pattern matching, since it will
  # always be met by the default if nothing is given
  def join(a, b, sep \\ " ") do
    a <> sep <> b
  end
end

IO.puts Concat.join("Hello", "world")  # returns Hello world
IO.puts Concat.join("Hello", "world", "_")  # returns Hello_world


# Here a seperate function def without a body must be used to declare defaults
# since the function join has multiple clauses
defmodule Concat2 do
  def join(a, b \\ nil, sep \\ " ")

  # leading underscore (_sep) means a variable will be ignored in this function
  def join(a, b, _sep) when is_nil(b) do
    a
  end

  def join(a, b, sep) do
    a <> sep <> b
  end
end

IO.puts Concat2.join("Hello", "world")      #=> Hello world
IO.puts Concat2.join("Hello", "world", "_") #=> Hello_world
# can leave out b despite lack of join that doesn't take it due to nil default
IO.puts Concat2.join("Hello")               #=> Hello
