defmodule HTTParrot.StreamHandler do
  @moduledoc """
  Returns GET data.
  """
  alias HTTParrot.GeneralRequestInfo
  use HTTParrot.Cowboy, methods: ~w(GET HEAD OPTIONS)

  @doc """
    `n` must be an integer between 1-100
  """
  def malformed_request(req, state) do
    {n, req} = :cowboy_req.binding(:n, req)
    try do
      n = n |> String.to_integer |> min(100) |> max(1)
      {false, req, n}
    rescue
      ArgumentError -> {true, req, state}
    end
  end

  def content_types_provided(req, state) do
    {[{{"application", "json", []}, :get_json}], req, state}
  end

  def get_json(req, n) do
    {info, req} = GeneralRequestInfo.retrieve(req)
    {{:chunked, stream_response(n, info)}, req, nil}
  end

  defp stream_response(n, info) do
    fn(send_func) ->
      Enum.each 0..n-1, fn (i) ->
        send_func.([id: i] ++ info |> JSEX.encode!)
      end
    end
  end
end
