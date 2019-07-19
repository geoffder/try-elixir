defmodule KV.Supervisor do
  @moduledoc """
  Supervisor module for the KV.Registry process.

  From the elixir OTP guide:
  Once the supervisor starts, it will traverse the list of children and it
  will invoke the child_spec/1 function on each module.

  The child_spec/1 function returns the child specification which describes
  how to start the process, if the process is a worker or a supervisor, if the
  process is temporary, transient or permanent and so on. The child_spec/1
  function is automatically defined when we `use Agent`, `use GenServer`, and
  `use Supervisor`.
  """
  use Supervisor

  def start_link(opts) do
    Supervisor.start_link(__MODULE__, :ok, opts)
  end

  @doc """
  Only one child -> KV.Registry, and our strategy :one_for_all dicates that if
  one of the children fails, we will kill and restart ALL of the children.
  The buckets and the registry are useless without the other, so this makes
  sense. :one_for_one could leave you with orphan processes.

  We use a DynamicSupervisor to watch over our buckets, since we don't know
  what, and how many, the children of the supervisor will be. See KV.Registry
  for how this is used to replace the start_link pattern used previously. If
  a bucket spawned with start_link were to crash, it would have brought down
  the whole registry, losing all of our state.
  """
  @impl true
  def init(:ok) do
    children = [
      {KV.Registry, name: KV.Registry},
      {DynamicSupervisor, name: KV.BucketSupervisor, strategy: :one_for_one}
    ]

    Supervisor.init(children, strategy: :one_for_all)
  end
end
