defmodule Math do
  def sum(a, b) do
    a + b
  end
end

defmodule Loop do
    def print(msg, n) when n >= 1 do
        IO.puts msg
        print(msg, n-1)
    end

    def print(msg, n) do
        IO.puts msg
    end
end

defmodule CountDown do
    def count(n) when n >= 1 do
        IO.puts n
        count(n-1)
    end

    def count(n) do
        IO.puts n
    end
end
