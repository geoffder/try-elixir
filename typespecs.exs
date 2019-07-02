# elixir is dynamically typed, but typespecs are available for declaring typed
# function signatures and declaring custom data types

# typed signature of round/1 which takes floats or ints and returns integer
# round(number) :: integer

defmodule LousyCalculator do
  @typedoc """
  Number followed by a string in a tuple.
  Attribute used here to store the type for reuse (convenience)
  """
  @type number_with_remark :: {number, String.t}

  @spec add(number, number) :: number_with_remark
  def add(x, y), do: {x + y, "Need a calculator for this?"}

  @spec multiply(number, number) :: number_with_remark
  def multiply(x, y), do: {x * y, "Wow!"}
end

defmodule QuietCalculator do
  @spec add(number, number) :: number
  def add(x, y), do: make_quiet(LousyCalculator.add(x, y))

  # we can ust the custom type defined in LousyCalculator here
  @spec make_quiet(LousyCalculator.number_with_remark) :: number
  defp make_quiet({num, _remark}), do: num
end

# if you want a custom type to be private, use @typep when you define it.

# Defining behaviours is a way to keep modules in line with eachother, so that
# we write them so that they *behave* the same way. Violating the expected
# behaviours will issue us a warning.

# here is a behaviour
defmodule Parser do
  @callback parse(String.t) :: {:ok, term | {:error, String.t}}
  @callback extensions() :: [String.t]
end

# modules that adopt this Parser behaviour have to implement all of the
# functions defined with the @callback directive

defmodule JSONParser do
  @behaviour Parser

  @impl Parser  # following function is an implementation of Parser behaviour
  def parse(str), do: {:ok, "some json " <> str}  # do stuff

  @impl Parser
  def extensions, do: ["json"]
end

defmodule YAMLParser do
  @behaviour Parser

  @impl Parser
  def parse(str), do: {:ok, "some yaml " <> str} # ... parse YAML

  @impl Parser
  def extensions, do: ["yml"]
end

