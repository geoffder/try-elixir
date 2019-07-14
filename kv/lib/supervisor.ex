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
  Only one child -> KV.Registry, and our strategy :one_for_one dicates that if
  one of the children fails, only that child will be restarted.
  """
  @impl true
  def init(:ok) do
    children = [
      {KV.Registry, name: KV.Registry}
    ]

    Supervisor.init(children, strategy: :one_for_one)
  end
end
