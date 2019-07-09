defmodule KV.Bucket do
  use Agent

  @doc """
  Starts a new bucket
  """
  def start_link(_opts) do
    Agent.start_link(fn -> %{} end)
  end

  @doc """
  Gets a value from the given 'bucket' by given 'key'
  """
  def get(bucket, key) do
    # I implemented it this way, and it worked. There is a shorter way though
    Agent.get(bucket, fn state -> Map.get(state, key) end)
    # first argument is agent state, exactly like anon func above.
    # Agent.get(bucket, &Map.get(&1, key))
  end

  @doc """
  Puts the 'value' for the given 'key' into the given 'bucket'
  """
  def put(bucket, key, value) do
    # same with above, the way I used worked, but it can be shorter.
    Agent.update(bucket, fn state -> Map.put(state, key, value) end)
    # first argument is agent state, exactly like anon func above.
    # Agent.put(bucket, &Map.put(&1, key, value))
  end

  @doc """
  Delete 'key' from 'bucket'.

  Returns current value of 'key', if it exists.
  """
  def delete(bucket, key) do
    Agent.get_and_update(bucket, &Map.pop(&1, key))
  end

  @doc """
  Not actually a useful function, but an example to remember when considering
  where (client/server <-> main-process/sub-process).

  Here we can think of anything that happens outside of the agent as the
  client, and inside of it, the server. When a long action is performed on the
  server, all other requests to that particular server will wait until the
  action is done, which may cause some clients to timeout.
  """
  def sleepy_delete(bucket, key) do
    # puts client to sleep (not in sub-process yet)
    Process.sleep(1000)

    Agent.get_and_update(bucket, fn dict ->
      # puts server to sleep (within agent sub-process)
      Process.sleep(1000)
      Map.pop(dict, key)
    end)
  end
end
