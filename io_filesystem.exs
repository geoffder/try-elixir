# I've already use IO.puts a lot, it writes to standard output (:stdio)
IO.puts "foobar"

# IO.gets takes user input to standard input
IO.puts "#{inspect IO.gets("yes or no? ")}"

# By default, functions in the IO module read from the standard input and write
# to the standard output. We can change this by passing another io device to
# the IO function call though. Here we use the standard error device.
IO.puts(:stderr, "hello world")
IO.puts ""

# The File module allows us to open files as IO devices, so we can use IO
# functions to read/write from/to them.
# File.open/2 (file_name, [options])
{:ok, file} = File.open("hello", [:write])  # in write mode
# by default files are opened in binary mode, so we have to use the specific
# IO.binread/2 and IO.binwrite/2 functions to interact with them.
IO.binwrite(file, "world")
File.close(File)
IO.puts "#{inspect File.read("hello")}"

# filesystem functions
File.mkdir("testdir")  # make directory
File.mkdir_p("parent/child")  # make directory and all parent directories
File.cp_r("test", "test_copy") # copy files/directories recursively

# remove files and directories recursively with File.rm_rf/1
File.rm_rf("testdir")
File.rm_rf("parent")
File.rm_rf("test_copy")

# Functions in the file module have variants with trailing bang (!) symbols
# in their names. These return only the content of the file instead of a tuple.
IO.puts "File.read -> #{inspect File.read("hello")}"
IO.puts "File.read! -> #{inspect File.read!("hello")}"
IO.puts ""
# if anything goes wrong with the ! variants the function raises an error
# The non-! variant is preferred when you want to handle different outcomes
# using pattern matching.
case File.read("hello") do
  {:ok, body} -> IO.puts body  # do something with the file contents
  {:error, reason} -> IO.puts "error occured: #{reason}"  # would handle here
end
IO.puts ""
# NOTE: If you expect the file to be there, it may be better to use the !
# variant as it will raise a meaningful error message and you don't have to
# handle/write that stuff yourself.

File.rm("hello")  # remove/delete named/pathed file

# The Path module, similar to os.path in python helps with file paths
IO.puts Path.join("foo", "bar")
IO.puts Path.expand("~/hello")  # expands out the unix home ~ contraction
IO.puts Path.expand("")  # full path to the current working directory
IO.puts ""

# The IO module is actually working with processes, so we are spawning new
# processes when we open files, and sending messages to those processes when we
# want to write to or read from them.
# As an example, lets spawn a process that prints messages sent to it
pid = spawn fn ->
  receive do: (msg -> IO.inspect msg)
end
# then try to write to it (msg will be printed then an error will raise)
# doing this with a process, so the IO.write failure does not crash shell
spawn fn -> IO.write(pid, "hello") end
