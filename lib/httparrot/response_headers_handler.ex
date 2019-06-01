defmodule HTTParrot.ResponseHeadersHandler do
  @moduledoc """
  Returns given response headers.
  """
  use HTTParrot.Cowboy, methods: ~w(GET HEAD OPTIONS)

  def malformed_request(req, state) do
    {qs_vals, req} = :cowboy_req.parse_qs(req)

    if not Enum.empty?(qs_vals) do
      {false, req, qs_vals}
    else
      {true, req, state}
    end
  end

  def content_types_provided(req, state) do
    {[{{"application", "json", []}, :get_json}], req, state}
  end

  def get_json(req, qs_vals) do
    req =
      Enum.reduce(qs_vals, req, fn {key, value}, req ->
        :cowboy_req.set_resp_header(key, value, req)
      end)

    {response(qs_vals), req, qs_vals}
  end

  defp response(qs_vals) do
    qs_vals |> JSX.encode!()
  end
end
