defmodule HTTParrot.StreamBytesHandler do
  @moduledoc """
  Streams n bytes of data, with chunked transfer encoding.
  """
  use HTTParrot.Cowboy, methods: ~w(GET)

  def content_types_provided(req, state) do
    {[{{"application", "octet-stream", []}, :get_bytes}], req, state}
  end

  def malformed_request(req, state) do
    n = :cowboy_req.binding(:n, req)
    %{seed: seed} = :cowboy_req.match_qs([{:seed, [], "1234"}], req)
    %{chunk_size: chunk_size} = :cowboy_req.match_qs([{:chunk_size, [], "1024"}], req)

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
    req = stream_response!(n, chunk_size, req)
    {:stop, req, nil}
  end

  defp stream_response!(n, chunk_size, req) do
    req = :cowboy_req.stream_reply(200, %{"content-type" => "application/octet-stream"}, req)

    Stream.repeatedly(fn -> :rand.uniform(255) end)
    |> Stream.take(n)
    |> Enum.chunk_every(chunk_size, chunk_size, [])
    |> Enum.each(fn chunk ->
      :cowboy_req.stream_body(List.to_string(chunk), :nofin, req)
    end)

    :cowboy_req.stream_body("", :fin, req)
    req
  end
end
