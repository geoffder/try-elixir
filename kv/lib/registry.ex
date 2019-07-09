defmodule KV.Registry do
  use GenServer

  # Callbacks

  @impl true
  def init(stack) do
    # initialize the state
    {:ok, stack}
  end

  @impl true
  def handle_call({:lookup, name}, _from, names) do
    # don't care where it came from here, GenServer handles the reply
    {:reply, Map.fetch(names, name), names}
  end

  @impl true
  def handle_cast({:create, name}, names) do
    if Map.has_key?(names, name) do
      # return same state, no new bucket created/registered
      {:noreply, names}
    else
      # create a new bucket process
      {:ok, bucket} = KV.Bucket.start_link([])
      # add a new name => bucket pair to the registry state map (return)
      {:noreply, Map.put(names, name, bucket)}
    end
  end

  ## Client API
  # Simple abstractions of the GenServer call in this case.
  # Could be in a seperate module if desired (replace __MODULE__ with name)

  @doc """
  Starts the registry.
  __MODULE__ means the current module.
  """
  def start_link(opts) do
    GenServer.start_link(__MODULE__, :ok, opts)
  end

  @doc """
  Looks up the bucket pid for `name` stored in `server`.
  Returns `{:ok, pid}` if the bucket exists, `:error` otherwise.
  """
  def lookup(server, name) do
    GenServer.call(server, {:lookup, name})
  end

  @doc """
  Ensures there is a bucket associated with the given `name` in `server`.
  """
  def create(server, name) do
    GenServer.cast(server, {:create, name})
  end
end
