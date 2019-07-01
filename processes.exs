# Processes as isolated, run concurrently, and communicate with eachoter via
# message passing. They are relatively lightweight, so running 10s to 100s of
# thousands at the same time isn't uncommon.

# spawn a new process to run a function
pid = spawn fn -> 1 + 2 end
# an identifier for the spawned process is returned
IO.puts "process identifier -> " <> Kernel.inspect(pid)
# since this process just ran (1 + 2) it will have already completed and died
IO.puts "Process.alive?(pid) -> " <> Kernel.inspect(Process.alive?(pid))

# we can get the PID for the current process with self/0 (no args)
IO.puts "current process PID (self) -> " <> "#{inspect pid}"
IO.puts ""

# send/2 and receive/1 are used can be used to get processes to talk
send self(), {:hello, "world"} # message is now in the "mailbox" of self()
# we can get this process to check itself mailbox for messages that match
# patterns defined in a recieve block. This will wait and continute to check
# when new messages are recieved until it either finds a match or it times out
message = receive do
  {:hello, msg} -> msg
  {:world, _msg} -> "won't match"
after
  # can specify a timeout of 0 if a message is already expected to be in the
  # mailbox at the time of running a receive block. (like in this case)
  # 0 -> "nothing already in mailbox"
  1_000 -> "nothing after 1s"
end
IO.puts "message from self -> " <> message

# spawn a process and send a message back to the parent process
parent = self()
spawn fn -> send(parent, {:hello, self()}) end
# recieve message in current process (the parent)
message = receive do
  {:hello, pid} -> "Got hello from #{inspect pid}"
end
IO.puts message

# processes are isolated, so if one fails, the others will be unaffected
IO.puts "current process -> #{inspect self()}"
spawn fn -> raise "oops" end  # error message from child appears
IO.puts "main process still going..."
# failure from one process can be propagated to another with spawn_link
# this time the error that appears is from the current process PID
# spawn_link fn ->  raise "oops" end

_ = """
From the Getting Started guide (good context):
Processes and links play an important role when building fault-tolerant
systems. Elixir processes are isolated and don’t share anything by default.
Therefore, a failure in a process will never crash or corrupt the state of
another process. Links, however, allow processes to establish a relationship
in case of failure. We often link our processes to supervisors which will
detect when a process dies and start a new process in its place.
"""

# spawn/1 and spawn_link/1 are basic primitives for creating processes, but
# most of the time we'll use abstractions built on top of them to do more.
# Task.start/1 and Task.start_link/1 return {:ok, pid} rather than just pid
# also it provides better error reports.
# Task module also has Task.async/1 and Task.await/1 which I'll want to learn.
Task.start fn -> raise "oops" end
