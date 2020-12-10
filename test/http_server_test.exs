defmodule HttpServerTest do
  use ExUnit.Case

  alias Servy.HttpServer

  test "req resp" do
    spawn(HttpServer, :start, [4000])

    url = "http://localhost:4000/wildthings"

    1..5
    |> Enum.map(fn(_) -> Task.async(fn -> HTTPoison.get(url) end) end)
    |> Enum.map(&Task.await/1)
    |> Enum.map(&assert_response/1)
  end

  defp assert_response({:ok, response}) do
    assert response.status_code == 200
    assert response.body == "Bears, Lions, Tigers, Hamsters"
  end
end
