defmodule Servy.Plugins do
  alias Servy.Conv
  alias Servy.FourOhFourCounter
  require Logger

  def rewrite_path(%Conv{path: "/wildlife"} = conv) do
    %{conv | path: "/wildthings"}
  end

  def rewrite_path(%Conv{} = conv), do: conv

  def log(%Conv{} = conv) do
    if Mix.env == :dev do
      IO.inspect(conv)
    end
    conv
  end

  def track(%Conv{status: 404, path: path} = conv) do
    if Mix.env != :test do
      Logger.warn("No #{path} here!")
      FourOhFourCounter.bump_count(path)
    end
    conv
  end

  def track(%Conv{} = conv), do: conv

  def emojify(%Conv{status: 200} = conv) do
    emojies = String.duplicate("🎉", 5)
    body = emojies <> "\n" <> conv.resp_body <> "\n" <> emojies

    %{conv | resp_body: body}
  end

  def emojify(%Conv{} = conv), do: conv

  def put_resp_content_type(conv, content_type) do
    headers = Map.put(conv.resp_headers, "Content-Type", content_type)
    %{conv | resp_headers: headers}
  end

  def put_content_length(conv) do
    headers = Map.put(conv.resp_headers, "Content-Length", String.length(conv.resp_body))
    %{conv | resp_headers: headers}
  end
end
