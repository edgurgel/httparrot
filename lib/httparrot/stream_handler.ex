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
    n = :cowboy_req.binding(:n, req)

    try do
      n = n |> String.to_integer() |> min(100) |> max(1)
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
    req = :cowboy_req.stream_reply(200, %{ "content-type" => "application/json" }, req)
    Enum.each(0..(n - 1), fn i ->
      body = JSX.encode!([id: i] ++ info)
      :cowboy_req.stream_body(body, :nofin, req)
    end)
    :cowboy_req.stream_body("", :fin, req)
    {:stop, req, nil}
  end
end
