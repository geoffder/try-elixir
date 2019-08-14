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
    # Read line at a time from the accepted socket connection and write the
    # lines back to the same socket.

    # Pipeline equivalent to write_line(read_line(socket), socket), so first
    # arg is the data moving through the pipe, and we provide the connected
    # socket as the second argument (to write to).
    socket
    |> read_line()
    |> write_line(socket)

    serve(socket)
  end

  defp read_line(socket) do
    {:ok, data} = :gen_tcp.recv(socket, 0)
    data
  end

  defp write_line(line, socket) do
    :gen_tcp.send(socket, line)
  end
end
