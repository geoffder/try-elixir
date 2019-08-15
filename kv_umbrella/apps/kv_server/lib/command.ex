defmodule KVServer.Command do
  @moduledoc """
  Module allowing users to issue commands to the KVServer. This is also an
  exercise in using doctests.
  """

  @doc ~S"""
  Parses the given `line` into a command.

  ## Examples


  iex> KVServer.Command.parse("CREATE shopping\r\n")
  {:ok, {:create, "shopping"}}

  # note trailing whitespace
  iex> KVServer.Command.parse "CREATE  shopping  \r\n"
  {:ok, {:create, "shopping"}}

  iex> KVServer.Command.parse "PUT shopping milk 1\r\n"
  {:ok, {:put, "shopping", "milk", "1"}}

  iex> KVServer.Command.parse "GET shopping milk\r\n"
  {:ok, {:get, "shopping", "milk"}}

  iex> KVServer.Command.parse "DELETE shopping eggs\r\n"
  {:ok, {:delete, "shopping", "eggs"}}

  Unknown commands or commands with the wrong number of arguments return an
  error:

  iex> KVServer.Command.parse "UNKNOWN shopping eggs\r\n"
  {:error, :unknown_command}

  iex> KVServer.Command.parse "GET shopping\r\n"
  {:error, :unknown_command}


  """
  def parse(line) do
    case String.split(line) do
      ["CREATE", bucket] -> {:ok, {:create, bucket}}
      ["PUT", bucket, key, value] -> {:ok, {:put, bucket, key, value}}
      ["GET", bucket, key] -> {:ok, {:get, bucket, key}}
      ["DELETE", bucket, key] -> {:ok, {:delete, bucket, key}}
      _ -> {:error, :unknown_command}
    end
  end

  @doc """
  Runs the given command (tuple from parse).
  """
  def run({:create, bucket}) do
    KV.Registry.create(KV.Registry, bucket)
    {:ok, "OK, #{bucket} bucket was created.\r\n"}
  end

  def run({:put, bucket, key, value}) do
    case KV.Registry.lookup(KV.Registry, bucket) do
      {:ok, pid} ->
        KV.Bucket.put(pid, key, value)
        {:ok, "OK, #{value} #{key} was placed in #{bucket} bucket.\r\n"}

      :error ->
        :error
    end
  end

  def run({:get, bucket, key}) do
    case KV.Registry.lookup(KV.Registry, bucket) do
      {:ok, pid} ->
        case KV.Bucket.get(pid, key) do
          nil ->
            {:ok, "NOPE, there is no #{key} in #{bucket} bucket.\r\n"}

          value ->
            {:ok, "OK, there is #{value} #{key} in #{bucket} bucket.\r\n"}
        end

      :error ->
        :error
    end
  end

  def run({:delete, bucket, key}) do
    case KV.Registry.lookup(KV.Registry, bucket) do
      {:ok, pid} ->
        KV.Bucket.delete(pid, key)
        {:ok, "OK, #{key} has been removed from #{bucket} bucket.\r\n"}

      :error ->
        :error
    end
  end
end
