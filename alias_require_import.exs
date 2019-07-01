# nested modules for alias example
defmodule Nested do
  defmodule Sum do
    def add(a, b) do
      a + b
    end
  end
end

# aliases are "lexically scoped", so they are only relevant in the block scope
# in which they are defined. Here we use it at the level of the module,
# but we could also put it in the def to restrict its scope.

defmodule Stats do
  alias Nested.Sum, as: Sum
  # now for the rest of this module definition we can use Sum, instead of
  # Nested.Sum to access the functions we want
  def add(a, b) do
    Sum.add(a, b)
  end
end

IO.puts "2 + 2 = #{Stats.add(2, 2)}"

# Elixir provides macros to generate commonly useful code (containing module
# definitions) at compile time. We gain access to them with "require"
require Integer
IO.puts "Integer.is_odd(3) -> #{inspect Integer.is_odd(3)}"

# Like alias, require is lexically scoped. You can imagine replacing the
# require with the block defining the module being brought in. So just like
# defmodule, it belongs to whatever scope it resides in.

# Elixir also has an import, which works similar to python, allowing us to
# bring in only the functions we want from a module, rather than the whole
# thing.
import Math, only: [sum: 2]  # only the function sum/2
IO.puts "2 + 2 = #{sum(2, 2)}"

# can also do:
import Integer, only: :macros  # imports all the macros
import Integer, only: :functions  # imports all the functions

# like alias and require, import is also lexically scoped!
# NOTE: import-ing a module automatically require-s it.

# the use macro is the most complicated all of these, as it allows the use-d
# module to inject ANY code in to the current module, such as importing itself,
# of other modules, defining new functions, setting a module state, etc.

ExUnit.start()
defmodule AssertionTest do
  @moduledoc """
  From elixir-lang getting-started:
  use requires the given module (for writing tests with ExUnit framework)
  then, it calls the __using__/1 callback on it which allows it to inject
  code in to the current context.

  Some modules (for example, the above ExUnit.Case, but also Supervisor and
  GenServer) use this mechanism to populate your module with some basic
  behaviour, which your module is intended to override or complete.
  """
  use ExUnit.Case, aysnc: true
  # compiles into ->
  #   require ExUnit.Case
  #   ExUnit.Case.__using__(async: true)
  test "always pass" do
    assert true
  end
end

# a bit more detail on aliases:
# An alias in elixir is a capitalized identifier, and they are converted to
# atoms during compilations. Example..
IO.puts "is_atom(String) -> #{inspect is_atom(String)}"
IO.puts "to_string(String) -> " <> Kernel.to_string(String)
IO.puts :"Elixir.String" == String

# Final note
# you can alis/import/require/use mutliple modules at once for convenience
# for example: alias MyApp.{Foo, Bar, Baz}
