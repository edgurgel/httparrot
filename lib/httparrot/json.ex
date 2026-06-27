defmodule HTTParrot.JSON do
  @moduledoc """
  JSON helpers built on Jason.

  Recursively converts keyword lists and lists of two-element tuples into
  `Jason.OrderedObject` so they encode as JSON objects, matching the behavior
  of the former JSX integration.
  """

  def encode!(data) do
    Jason.encode!(to_jason(data))
  end

  def decode!(data) do
    Jason.decode!(data)
  end

  def is_json?(data) do
    match?({:ok, _}, Jason.decode(data))
  end

  def prettify!(data) do
    Jason.encode!(Jason.decode!(data), pretty: true)
  end

  defp to_jason([{_, _} | _] = kw) when is_list(kw) do
    Jason.OrderedObject.new(Enum.map(kw, &to_jason/1))
  end

  defp to_jason([{}]), do: Jason.OrderedObject.new([])

  defp to_jason({key, value}) do
    {to_jason_key(key), to_jason(value)}
  end

  defp to_jason(list) when is_list(list) do
    Enum.map(list, &to_jason/1)
  end

  defp to_jason(map) when is_map(map) do
    Map.new(map, fn {key, value} -> {to_jason_key(key), to_jason(value)} end)
  end

  defp to_jason(other), do: other

  defp to_jason_key(key) when is_atom(key), do: Atom.to_string(key)
  defp to_jason_key(key), do: key
end
