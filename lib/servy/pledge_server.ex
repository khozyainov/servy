defmodule Servy.PledgeServer do

  @name :pledge_server

  use GenServer

  def start_link(_arg) do
    IO.puts "Starting the pledge server..."
    GenServer.start_link(__MODULE__, [], name: @name)
  end

  def create_pledge(name, amount) do
    GenServer.call @name, {:create_pledge, name, amount}
  end

  def recent_pledges do
   GenServer.call @name, :recent_pledges
  end

  def total_pledge do
    GenServer.call @name, :total_pledges
  end

  def clear do
    GenServer.cast @name, :clear
  end

  def handle_call({:create_pledge, name, amount}, _from, state) do
    {:ok, id} = send_pledge_to_service(name, amount)
    most_recent_pledges = Enum.take(state, 2)
    new_state = [ {name, amount} | most_recent_pledges ]
    {:reply, id, new_state}
  end

  def handle_call(:recent_pledges, _from, state) do
    {:reply, state, state}
  end

  def handle_call(:total_pledged, _from, state) do
    total = Enum.map(state, &elem(&1, 1)) |> Enum.sum
    {:reply, total, state}
  end

  def handle_cast(:clear, _state) do
    {:noreply, []}
  end

  defp send_pledge_to_service(_name, _amount) do
    # Sending to externap api
    {:ok, "pledge-#{:rand.uniform(1000)}"}
  end
end
