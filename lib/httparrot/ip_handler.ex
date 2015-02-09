defmodule HTTParrot.IPHandler do
  @moduledoc """
  Returns Origin IP
  """
  use HTTParrot.Cowboy, methods: ~w(GET HEAD OPTIONS)

  def content_types_provided(req, state) do
    {[{{"application", "json", []}, :get_json}], req, state}
  end

  def get_json(req, state) do
    {{ip, _port}, req} = :cowboy_req.peer(req)
    {response(ip), req, state}
  end

  defp response(ip) do
    ip = :inet_parse.ntoa(ip) |> to_string
    [origin: ip] |> JSX.encode!
  end
end
