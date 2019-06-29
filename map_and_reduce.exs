# More recurrsion practice. The Enum module is the typical way to do this
# sort of thing, but these are a couple implementation examples.

defmodule Reduce do
  def sum_list(a, accumulator \\ 0)  # by default, start from zero

  # pattern matching to assign head and tail of list to variables
  def sum_list([head | tail], accumulator) do
    sum_list(tail, head + accumulator)
  end

  # nothing left to sum (no tail in one element list)
  def sum_list([], accumulator) do
    accumulator
  end
end

IO.puts "sum [1, 2, 3] -> " <> Kernel.inspect(Reduce.sum_list([1, 2, 3]))


defmodule Map do
  # returns list, but only after all calls are completed
  def mul([head | tail], b) do
    [head*b | mul(tail, b)]
  end

  # when the last element is multiplied (no tail)
  def mul([], b) do
    []
  end
end

IO.puts "Map.mul([1, 2, 3], 5) -> " <> Kernel.inspect(Map.mul([1, 2, 3], 5))
