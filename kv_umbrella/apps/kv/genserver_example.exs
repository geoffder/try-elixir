defmodule Stack do
  use GenServer

  # Callbacks (init is the only REQUIRED one)
  @impl true  # indicates this is a callback implementation
  def init(stack) do
    {:ok, stack}
  end

  @impl true
  def handle_call(:pop, _from, [head | tail]) do
    # :reply pattern matches callback (tells GenServer what to do)
    # second element (head) is the value to return
    # third element (tail) is the new value of the state
    {:reply, head, tail}
  end

  @impl true
  def handle_cast({:push, element}, state) do
    # tells GenServer callback to not reply (obviously)
    # replace state with provided list (new element at head)
    {:noreply, [element | state]}
  end
end

# Start the server
{:ok, stack_pid} = GenServer.start_link(Stack, [:hello])

# Example client actions (interacting with the server)

# GenServer.call -> matching handle_call callback implemented in Stack
IO.puts inspect GenServer.call(stack_pid, :pop)  # => :hello

IO.puts inspect GenServer.cast(stack_pid, {:push, :world})  # => :ok

IO.puts inspect GenServer.call(stack_pid, :pop)  # => :world
