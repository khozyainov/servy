defmodule Servy.PledgeController do
  alias Servy.PledgeServer
  import Servy.PledgeView, only: [recent_pledges: 1, new_pledge: 0]

  def create(conv, %{"name" => name, "amount" => amount}) do
    PledgeServer.create_pledge(name, String.to_integer(amount))
    pledges = PledgeServer.recent_pledges()

    %{conv | status: 201, resp_body: recent_pledges(pledges)}
  end

  def index(conv) do
    pledges = PledgeServer.recent_pledges()

    %{conv | status: 200, resp_body: recent_pledges(pledges)}
  end

  def new(conv) do
    %{conv | status: 200, resp_body: new_pledge()}
  end
end
