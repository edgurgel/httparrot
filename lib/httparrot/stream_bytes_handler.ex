defmodule HTTParrot.StreamBytesHandler do
  @moduledoc """
  Streams n bytes of data, with chunked transfer encoding.
  """
  use HTTParrot.Cowboy, methods: ~w(GET)

  def content_types_provided(req, state) do
    {[{{"application", "octet-stream", []}, :get_bytes}], req, state}
  end

  def malformed_request(req, state) do
    {n, req} = :cowboy_req.binding(:n, req)
    {seed, req} = :cowboy_req.match_qs(["seed", req], "1234")
    {chunk_size, req} = :cowboy_req.match_qs(["chunk_size", req], "1024")

    try do
      n = n |> String.to_integer()
      seed = seed |> String.to_integer()
      chunk_size = chunk_size |> String.to_integer()
      {false, req, {n, seed, chunk_size}}
    rescue
      ArgumentError -> {true, req, state}
    end
  end

  def get_bytes(req, state) do
    {n, seed, chunk_size} = state
    :rand.seed(:exs64, {seed, seed, seed})
    {{:chunked, stream_response(n, chunk_size)}, req, nil}
  end

  defp stream_response(n, chunk_size) do
    fn send_func ->
      Stream.repeatedly(fn -> :rand.uniform(255) end)
      |> Stream.take(n)
      |> Enum.chunk_every(chunk_size, chunk_size, [])
      |> Enum.each(fn chunk ->
        send_func.(List.to_string(chunk))
      end)
    end
  end
end
