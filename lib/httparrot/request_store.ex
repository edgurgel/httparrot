defmodule HTTParrot.RequestStore do
  @moduledoc """
  Used to store and retrieved requests
  """
  @doc """
  Store the requests to the key
  """
  def store(key, info) do
    map = retrieve(key) ++ [info]
    ConCache.put(:requests_registry, key, map)
  end

  @doc """
  Get the saved request using the key
  """
  def retrieve(key) do
    entry = ConCache.get(:requests_registry, key)

    case entry do
      nil ->
        []

      _ ->
        entry
    end
  end

  @doc """
  Clear the saved data on the corresponding key
  """
  def clear(key) do
    ConCache.delete(:requests_registry, key)
  end
end
