# new agent with starting state of an empty list
{:ok, agent} = Agent.start_link fn -> [] end

# the argument of anonymous functions passed to this agent on subsequent
# update calls refers to the current state of the agent

# here we use a [head | tail] pattern match to update the agents state with
# a new element at the front. :ok match will fail on error here.
:ok = Agent.update(agent, fn list -> ["eggs" | list] end)

# same idea wrt the argument of the anon function when using Agent.get()
IO.puts "agent state -> #{inspect Agent.get(agent, fn list -> list end)}"
:ok = Agent.stop(agent)
