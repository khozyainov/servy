defmodule Servy.Handler do
  alias Servy.BearController
  alias Servy.FourOhFourCounter
  alias Servy.Conv
  alias Servy.VideoCam

  @moduledoc "Handles HTTP requests."

  @pages_path Path.expand("pages", File.cwd!())

  import Servy.Parser, only: [parse: 1]
  import Servy.Plugins, only: [rewrite_path: 1, log: 1, track: 1, put_content_length: 1]
  import Servy.FileHandler, only: [handle_file: 2]

  @doc "Transforms request to response."
  def handle(request) do
    request
    |> parse
    |> rewrite_path
    |> log
    |> route
    |> track
    |> put_content_length
    |> format_response
  end

  def route(%Conv{method: "POST", path: "/pledges"} = conv) do
    Servy.PledgeController.create(conv, conv.params)
  end

  def route(%Conv{method: "GET", path: "/pledges"} = conv) do
    Servy.PledgeController.index(conv)
  end

  def route(%Conv{method: "GET", path: "/pledges/new"} = conv) do
    Servy.PledgeController.new(conv)
  end

  def route(%Conv{method: "GET", path: "/404s"} = conv) do
    counts = Servy.FourOhFourCounter.get_counts()

    %{conv | status: 200, resp_body: inspect counts}
  end

  def route(%Conv{method: "GET", path: "/snapshots"} = conv) do
    snapshots =
      ["cam-1", "cam-2", "cam-3"]
      |> Enum.map(&Task.async(fn -> VideoCam.get_snapshot(&1) end))
      |> Enum.map(&Task.await/1)

    %{conv | status: 200, resp_body: inspect(snapshots)}
  end

  def route(%Conv{method: "GET", path: "/wildthings"} = conv) do
    %{conv | status: 200, resp_body: "Bears, Lions, Tigers, Hamsters"}
  end

  def route(%Conv{method: "GET", path: "/api/bears"} = conv) do
    Servy.Api.BearController.index(conv)
  end

  def route(%Conv{method: "POST", path: "/api/bears"} = conv) do
    Servy.Api.BearController.create(conv, conv.params)
  end

  def route(%Conv{method: "GET", path: "/bears"} = conv) do
    BearController.index(conv)
  end

  def route(%Conv{method: "POST", path: "/bears"} = conv) do
    BearController.create(conv, conv.params)
  end

  def route(%Conv{method: "GET", path: "/bears/" <> id} = conv) do
    params = Map.put(conv.params, "id", id)
    BearController.show(conv, params)
  end

  def route(%Conv{method: "GET", path: "/bears/new"} = conv) do
    "form.html"
    |> get_content
    |> handle_file(conv)
  end

  def route(%Conv{method: "GET", path: "/about"} = conv) do
    "about.html"
    |> get_content
    |> handle_file(conv)
  end

  def route(%Conv{path: path} = conv) do
    %{conv | status: 404, resp_body: "No #{path} here!"}
  end

  def get_content(name) do
    @pages_path
    |> Path.join(name)
    |> File.read()
  end

  def format_response(conv) do
    """
    HTTP/1.1 #{Conv.full_status(conv)}\r
    Content-Type: #{conv.resp_headers["Content-Type"]}\r
    Content-Length: #{byte_size(conv.resp_body)}\r
    \r
    #{conv.resp_body}
    """
  end
end
