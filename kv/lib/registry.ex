defmodule KV.Registry do
  @moduledoc """
  Handles spawning of new KV.Bucket processes and assigns unique name strings
  to each.
  """
  use GenServer

  # Callbacks
  @impl true
  def init(:ok) do
    # initialize the state
    names = %{}
    refs = %{}
    {:ok, {names, refs}}
  end

  @impl true
  def handle_call({:lookup, name}, _from, state) do
    # can pattern match out the desired Map from the state here
    {names, _} = state
    # don't care where it came from here, GenServer handles the reply
    {:reply, Map.fetch(names, name), state}
  end

  @impl true
  def handle_call({:list_names}, _from, state) do
    {names, _} = state
    {:reply, for(pair <- names, do: elem(pair, 0)), state}
  end

  @doc """
  Note: can also pattern match out the parts of the state in the args to the
  function as well. As opposed to pattern used above in the handle_call[s]
  """
  @impl true
  def handle_cast({:create, name}, {names, refs}) do
    # if Map.has_key?(names, name) do
    #  # return same state, no new bucket created/registered
    #  {:noreply, {names, refs}}
    # else
    #  # create a new bucket process and get monitor reference
    #  {:ok, bucket} = KV.Bucket.start_link([])
    #  ref = Process.monitor(bucket)
    #  # add a new name => bucket pair to the registry state map (return)
    #  names = Map.put(names, name, bucket)
    #  refs = Map.put(refs, ref, name)
    #  {:noreply, {refs, names}}
    # end

    # the same thing, but with case pattern matching. I believe this is
    # similar to what the if macro is tranformed in to. Really just wanted to
    # practice the syntax.
    case Map.has_key?(names, name) do
      true ->
        {:noreply, {names, refs}}

      false ->
        {:ok, bucket} =
          DynamicSupervisor.start_child(
            KV.BucketSupervisor,
            KV.Bucket
          )

        # get a reference for the process (to match against :DOWN message)
        ref = Process.monitor(bucket)

        # update state Maps
        names = Map.put(names, name, bucket)
        refs = Map.put(refs, ref, name)

        # send updated state back to server
        {:noreply, {names, refs}}
    end
  end

  @doc """
  This will be called when it recieves a message indicating that a bucket has
  stopped (a tuple matching this pattern).
  """
  @impl true
  def handle_info({:DOWN, ref, :process, _pid, _reason}, {names, refs}) do
    # get the name corresponding to the process reference (, and the refs map
    # with that ref removed)
    {name, refs} = Map.pop(refs, ref)
    names = Map.delete(names, name)
    {:noreply, {names, refs}}
  end

  @doc """
  A catch-all handle_info/2 callback that does nothing with the messages we
  don't care about that our server might recieve. All messages that are not
  GenServer calls and casts must come in through handle_info, including
  regular send/2 messages.
  """
  @impl true
  def handle_info(_msg, state) do
    {:noreply, state}
  end

  ## Client API
  # Simple abstractions of the GenServer call in this case.
  # Could be in a seperate module if desired (replace __MODULE__ with name)

  @doc """
  Starts the registry.
  __MODULE__ means the current module.
  Returns {:ok, registry_pid} on success.
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
  Returns a list of the named processes in the registry
  """
  def list_names(server) do
    GenServer.call(server, {:list_names})
  end

  @doc """
  Create a bucket associated with the given `name` in `server`.
  No reply (return) is generated for the client.
  """
  def create(server, name) do
    GenServer.cast(server, {:create, name})
  end
end
