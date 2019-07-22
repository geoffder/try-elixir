defmodule KV.Registry do
  @moduledoc """
  Handles spawning of new KV.Bucket processes and assigns unique name strings
  to each. This updated version uses the :ets module from Erlang so that this
  server will not become a bottle nec in the case that many processes want to
  access buckets (thus would need to make calls to the registry to get pids).
  """
  use GenServer
  import Ex2ms
  ## Client API

  @doc """
  Starts the registry.
  __MODULE__ means the current module.
  Returns {:ok, registry_pid} on success.
  """
  def start_link(opts) do
    server_name = Keyword.fetch!(opts, :name)
    GenServer.start_link(__MODULE__, server_name, opts)
  end

  @doc """
  Create a bucket associated with the given `name` in `server`.
  Note the switch from cast -> call. Use synchronous call to avoid potential
  race conditions where a bucket is accessed before it has actually been
  created by an asynchronous cast.
  """
  def create(server, name) do
    GenServer.call(server, {:create, name})
  end

  @doc """
  Looks up the bucket pid for `name` stored in ETS, no need to call a server.
  Returns `[{name, pid}]` if the bucket exists, `[]` otherwise.
  We use the pin ^ operator here to match against the value of an existing
  variable, rather than assign the value from the right into it.
  """
  def lookup(server, name) do
    case :ets.lookup(server, name) do
      [{^name, pid}] -> {:ok, pid}
      [] -> :error
    end
  end

  @doc """
  Get list of all the bucket names tracked by the registry. Use Ex2ms (Elixir
  version of :ets.fun2ms) to create a match specification that can be passed
  to the select function. I want all of the names in this case, so no `when`.
  """
  def list_names(table) do
    get_names =
      fun do
        {name, _pid} -> name
      end

    # select will return a reverse chronological list, reverse it back.
    Enum.reverse(:ets.select(table, get_names))
  end

  ## Server Callbacks
  @impl true
  def init(table_name) do
    # initialize the globally readable ETS table
    names = :ets.new(table_name, [:named_table, read_concurrency: true])
    refs = %{}
    {:ok, {names, refs}}
  end

  @doc """
  If name is in the registry already, do nothing. Otherwise create a new
  dynamically supervised bucket, and store it's name, pid, and reference.
  """
  @impl true
  def handle_call({:create, name}, _from, {names, refs}) do
    case lookup(names, name) do
      {:ok, bucket_pid} ->
        {:reply, bucket_pid, {names, refs}}

      :error ->
        {:ok, bucket_pid} =
          DynamicSupervisor.start_child(
            KV.BucketSupervisor,
            KV.Bucket
          )

        # get a reference for the process (to match against :DOWN message)
        ref = Process.monitor(bucket_pid)
        refs = Map.put(refs, ref, name)

        # update ETS names table
        :ets.insert(names, {name, bucket_pid})

        # return the updated names and refs to the server
        {:reply, bucket_pid, {names, refs}}
    end
  end

  @doc """
  This will be called when it recieves a message indicating that a bucket has
  stopped (a tuple matching this pattern). Get the name corresponding to the
  process reference (, and the refs map with that ref removed).
  """
  @impl true
  def handle_info({:DOWN, ref, :process, _pid, _reason}, {names, refs}) do
    {name, refs} = Map.pop(refs, ref)
    :ets.delete(names, name)
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
end
