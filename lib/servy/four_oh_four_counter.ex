defmodule Servy.FourOhFourCounter do

  @name __MODULE__

  def start do
    pid = spawn(__MODULE__, :listen_loop, [%{}])
    Process.register(pid, __MODULE__)
  end

  def bump_count(path) do
    send @name, {:bump_count, path}
  end

  def get_count(path) do
    send @name, {self(), :get_count, path}

    receive do {:response, count} -> count end
  end

  def get_counts do
    send @name, {self(), :get_counts}

    receive do {:response, counts} -> counts end
  end

  def listen_loop(state) do
    receive do
      {:bump_count, path} ->
        new_state = Map.update(state, path, 1, &(&1 + 1))
        listen_loop(new_state)
      {sender, :get_count, path} ->
        send sender, {:response, Map.get(state, path, 0)}
        listen_loop(state)
      {sender, :get_counts} ->
        send sender, {:response, state}
        listen_loop(state)
      unexpected ->
        IO.puts "#{inspect unexpected}"
        listen_loop(state)
    end
  end
end
