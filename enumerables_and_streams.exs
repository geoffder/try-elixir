# Enum module provides a a way to work with enumerables like lists and maps

# Enum.map applies the supplied function to every element of an enumerable
# can define anonymous functions for the purpose in line for this purpose.
IO.puts Kernel.inspect(Enum.map([1, 2, 3], fn x -> x * 2 end))

# elixir provides range generation like pythons range(). Like range() and
# xrange() before it, this is lazy and doesn't produce a list automatically.
# here there is a single element list with a range in it.
range = [1..10]
IO.puts "range = [1..10] -> " <> Kernel.inspect(range)
IO.puts "length(range) -> " <> Kernel.inspect(length range)
IO.puts ""

# apply map over a range
mapped = Enum.map(1..5, fn x -> x * 3 end)
IO.puts "Enum.map(1..5, fn x -> x * 3 end) -> " <> Kernel.inspect(mapped)

# apply reduce over a range. Note the anonymous function definition
# &+/2: & captures reference. + is a function which takes /2 arguments.
reduced = Enum.reduce(1..3, 0, &+/2)
IO.puts "Enum.reduce(1..3, 0, &+/2) -> " <> Kernel.inspect(reduced)

# Note: these Enum operations are all Eager
# -> they perform computations immediately  and output a list/number/etc.

# We can build pipelines of operations using the |> operator which pass the
# output of each function to as the first argument to the next.
odd? = &(rem(&1, 2) != 0)
total = 1..100 |> Enum.map(&(&1 * 3)) |> Enum.filter(odd?) |> Enum.sum
IO.puts "total = " <> Kernel.inspect(total)

# one can also do this with Streams, which are lazy, composable enumerables
# Stream module operations output the stream datatype. Computations baked in to
# the stream will only execute when it is evaluated with Enum.

# in this example, rather than producing intermediate lists with each function
# in the pipeline, a stream is passed between them, composing the functions
streamEx = 1..100_000 |> Stream.map(&(&1 * 3)) |> Stream.filter(odd?)
IO.puts "non-evaluated streamEx: " <> Kernel.inspect streamEx
IO.puts "Enum.sum(streamEx) -> " <> Kernel.inspect Enum.sum(streamEx)

# Streams are very useful for very large or infinite things, avoids operating
# on the whole thing all at once.
stream = Stream.cycle([1, 2, 3])  # repeats infinitely
IO.puts "Stream.cycle([1, 2, 3]) -> " <> Kernel.inspect(stream)
IO.puts "Enum.take(stream, 10) -> " <> Kernel.inspect(Enum.take(stream, 10))
# you can use this to take only what is needed from a file as well
stream = File.stream!("example.txt")
IO.puts Enum.take(stream, 3)
