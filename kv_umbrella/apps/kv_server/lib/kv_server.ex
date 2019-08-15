defmodule KVServer do
  @moduledoc """
  TCP server implemenation using Erlang's :gen_tcp
  """
  require Logger

  @doc """
  :gen_tcp options used for this server:
  -> `:binary` - receives data as binaries (instead of lists)
  -> `packet: :line` - receive data line by line
  -> `active: false` - blocks on `:gen_tcp.recv/2` until data is available
  -> `reuseaddr: true` - allows us to reuse the address if listener crashes
  """
  def accept(port) do
    {:ok, socket} =
      :gen_tcp.listen(
        port,
        [:binary, packet: :line, active: false, reuseaddr: true]
      )

    Logger.info("Accepting connections on port #{port}")
    loop_acceptor(socket)
  end

  defp loop_acceptor(socket) do
    {:ok, client} = :gen_tcp.accept(socket)

    # Start temporary process to serve the incoming request to the socket.
    {:ok, pid} =
      Task.Supervisor.start_child(
        KVServer.TaskSupervisor,
        fn ->
          serve(client)
        end
      )

    # set the newly created child process to be the "controlling process" of
    # the client socket. This way the acceptor will not bring all of the
    # clients if it crashes. By default, sockets are tied to the process that
    # accepts them (which in this case is the Task that ran accept(port)).
    :ok = :gen_tcp.controlling_process(client, pid)

    # wait for the next request
    loop_acceptor(socket)
  end

  defp serve(socket) do
    # msg =
    #  case read_line(socket) do
    #    {:ok, data} ->
    #      case KVServer.Command.parse(data) do
    #        {:ok, command} ->
    #          KVServer.Command.run(command)

    #        {:error, _} = err ->
    #          err
    #      end

    #    {:error, _} = err ->
    #      err
    #  end

    # Rather than the heavily nested case block above, we can achieve the same
    # thing using the `with` construct in a way that more resembles a a data
    # pipeline. This retrieves the value returned from the right side of the
    # <- arrow and matches it against the pattern on the left side. If there
    # is an expression, `with` moves on to the next expression. If there is no
    # match, then the non-matching value is returned.
    msg =
      with {:ok, data} <- read_line(socket),
           {:ok, command} <- KVServer.Command.parse(data),
           do: KVServer.Command.run(command)

    # write the status (and command) back to the client socket
    write_line(socket, msg)

    # From the guide...
    # "Note that serve/1 is an infinite loop called sequentially inside
    # loop_acceptor/1, so the tail call to loop_acceptor/1 is never reached
    # and could be avoided."
    serve(socket)
  end

  defp read_line(socket) do
    :gen_tcp.recv(socket, 0)
  end

  defp write_line(socket, {:ok, text}) do
    :gen_tcp.send(socket, text)
  end
end
