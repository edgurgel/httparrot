defmodule HTTParrot.RequestStore do

  def store(key, info) do
    map = retrieve(key) ++ [info]
    ConCache.put(:requests_registry, key, map)
  end

  def retrieve(key) do
    entry = ConCache.get(:requests_registry, key)
    case entry do
    nil -> []
    _ ->
      entry
    end
  end

  def clear(key) do
    ConCache.delete(:requests_registry, key)
  end
end
