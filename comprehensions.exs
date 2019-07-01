# comprehensions are syntactic sugar for looping over enumerables
squared = for n <- 1..10, do: n*n
IO.puts inspect(squared)

# in the above example, n <- 1..10 is the "generator". It generates values to
# be used in the comprehension. Any enumerable can be passed on the right-hand
# side of the generator expression

# generator expressions also support pattern-matching on their left-hand side
values = [good: 1, good: 2, bad: 3, good: 4]
only_good = for {:good, n} <- values, do: n
IO.puts inspect(only_good)

# you can also use filters as an alternative to pattern matching
# bool (or anything vs nil) filter comes after the generator and before the do
multiple_of_3? = fn n -> rem(n, 3) == 0 end
multiples = for n <- 1..30, multiple_of_3?.(n), do: n
IO.puts inspect(multiples)

# So, I remember that we used pipes to compose Enum/Stream operations
# Can we do the same thing to make new anonymous functions for comprehension?
plus2 = &(&1 + 2)
times2 = &(&1 * 2)
IO.puts inspect(times2)
pipe = fn n -> Stream.map(n, plus2) |> Enum.map(times2) end
IO.puts inspect(pipe.(1..10))

# non-Enumerable version:
pipe2 = fn n -> plus2.(n) |> times2.() end
# This works with comprehension (one element at a time)!
IO.puts inspect(for n <- 1..10, do: pipe2.(n))

# So I can compose functions using pipes, then use the resulting anonymous
# function to perform comprehensions

# Same thing but without pre-definition of the pipeline.
# this might re-define the function every time though and it is harder to read,
# so probably not worth doing this way.
result = for n <- 1..10, do: (fn n -> plus2.(n) |> times2.() end).(n)
IO.puts inspect(result)
IO.puts ""

# One can also use multiple generators in a comprehension.
# This returns the size of all of the files in each of the listed directories
dirs = ['/home/geoff', '/home/geoff/GitRepos']
file_sizes = for dir <- dirs,
  file <- File.ls!(dir),  # for all of the files
  path = Path.join(dir, file),  # only exists inside this block
  File.regular?(path), # filter for paths to regular files
  do: File.stat!(path).size
  # alternative syntax: (makes sense if do will be multi-line)
  # File.regular?(path) do
  #   File.stat!(path).size
  # end
IO.puts inspect(file_sizes)

# another example. Much like multi-for python comprehensions
cartesian = for i <- [:a, :b, :c], j <- [1, 2], do: {i, j}
IO.puts inspect(cartesian)
IO.puts ""

# bitstring generators can also be used for comprehensions
# receive list of pixels from a binary with respective rgb values flattened
flat_pixels = <<213, 45, 132, 64, 76, 32, 76, 0, 0, 234, 32, 15>>
# pattern matching/encoding
pixels = for <<r::8, g::8, b::8 <- flat_pixels>>, do: {r, g, b}
IO.puts inspect(pixels)

# all of the comprehensions so far have output lists. The :into option can be
# used to have the result placed into a different data structure.
# :into accepts any structure that implements the Collectable protocol
# e.g. Sets, maps, and other dictionaries

# filter out spaces (?\s) and output result into a string.
str = for <<c <- " hello world ">>, c != ?\s, into: "", do: <<c>>
IO.puts str

# transform the values in a map
map = %{"a" => 1, "b" => 2, c: 3}
map = for {key, val} <- map, into: %{}, do: {key, val*val}
IO.puts inspect(map)

# Streams are both Enumerables and Collectables so they can be used in
# comprehensions as well
# This will trap the shell in this comprehension so Ctrl+C will be needed to
# escape.
stream = IO.stream(:stdio, :line)  # takes input from shell a line at a time
for line <- stream, into: stream do  # output to same stream
  String.upcase(line) <> "\n"  # converts input to UPPERCASE
end
