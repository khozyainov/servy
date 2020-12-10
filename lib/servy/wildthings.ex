defmodule Servy.Wildthings do
  alias Servy.Bear

  @bears_path Path.expand("db", File.cwd!())
  @bears_file "bears.json"

  def list_bears do
    @bears_path
    |> Path.join(@bears_file)
    |> read_json
    |> Poison.decode!(as: %{"bears" => [%Bear{}]})
    |> Map.get("bears")
  end

  defp read_json(path) do
    case File.read(path) do
      {:ok, content} ->
        content
      {:error, reason} ->
        IO.inspect "Error reading #{path}: #{reason}"
        "[]"
    end
  end

  def get_bear(id) when is_integer(id) do
    Enum.find(list_bears(), fn(b) -> b.id == id end)
  end

  def get_bear(id) when is_binary(id) do
    id |> String.to_integer |> get_bear
  end
end
