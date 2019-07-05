defmodule Stack do
  use GenServer

  # Callbacks

  @impl true
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
{:ok, pid} = GenServer.start_link(Stack, [:hello])
