_ = """
So far we haven't gone over anything about State in this guide. Processes are
the most common answer to the need for maintaining and modifying a program
state in memory. We can make modules that spawn infinitely looping processes
that store our State data.
"""

defmodule KV do
  @moduledoc """
  This module starts new processes that work as key-value stores.
  The new process waits for messages, performs the correct actions in response,
  then waits for another message.
  """

  def start_link do
    # start a new loop/1 with an empty map
    Task.start_link fn -> loop(%{}) end
  end

  defp loop(map) do
    receive do
      {:get, key, caller} ->
        send caller, {:KV_get, Map.get(map, key)}
        loop(map)
      {:put, key, value} ->
        loop(Map.put(map, key, value))
    end
  end
end

{:ok, pid} = KV.start_link
# gives process a name (anyone who knows it can send to it)
Process.register(pid, :kv)
send :kv, {:put, :hello, "world"}  # add hello: "world" pair to KV process
send :kv, {:get, :hello, self()}  # get value for :hello key
receive do
  {:KV_get, value} ->
    IO.puts "message received -> #{value}"
end

# The pattern used above with KV to maintain state and name registrations is
# very common, but we usually won't be doing it manually. The Agent module
# provies simple abstractions for this purpose.

# update and get use given anonymous function to update and read state
{:ok, pid} = Agent.start_link fn -> %{} end
IO.puts Agent.update(pid, fn map -> Map.put(map, :hello, :world) end)
IO.puts Agent.get(pid, fn map -> Map.get(map, :hello) end)
