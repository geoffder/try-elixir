defmodule KV do
  @moduledoc """
  Documentation for KV.
  """
  use Application

  @doc """
  When the application starts up, start up the Supervisor responsible for the
  registry.
  """
  def start(_type, _args) do
    KV.Supervisor.start_link(name: KV.Supervisor)
  end
end
