defmodule Servy.ServicesSupervisor do
  use Supervisor

  def start_link(_args) do
    IO.puts "starting services sup"
    Supervisor.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  def init(:ok) do
    children = [
      Servy.PledgeServer,
      {Servy.SensorServer, 60}
    ]

    Supervisor.init(children, strategy: :one_for_one)
  end
end
