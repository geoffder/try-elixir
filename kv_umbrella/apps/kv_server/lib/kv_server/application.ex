defmodule KVServer.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @doc """
  Start the accept loop of the server as a Task. Specify the port to listen on
  in command line when running application, e.g. `PORT=#### mix run --no-halt`
  Default port is 4040 if argument not given. Here we override the default
  child specification of Task to use a :permanent restart strategy, as
  opposed to temporary (so it will be restarted on failure).

  Additionally, we'll use Task.Supervisor to start temporary task processes
  from our loop_acceptor with a :one_for_one strategy so that failed requests
  and broken connections do not bring down our application. Our server which
  is running as a Task depends on this, so we need to start it first.
  """
  def start(_type, _args) do
    port = String.to_integer(System.get_env("PORT") || "4040")

    children = [
      {Task.Supervisor, name: KVServer.TaskSupervisor},
      Supervisor.child_spec(
        {Task, fn -> KVServer.accept(port) end},
        restart: :permanent
      )
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: KVServer.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
