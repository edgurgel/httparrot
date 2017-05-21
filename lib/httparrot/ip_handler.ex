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
    {:ok, forwarded_for, _} = :cowboy_req.parse_header(<<"x-forwarded-for">>, req)
    case forwarded_for do
      :undefined ->
        {response(ip), req, state}
      _ ->
        {response(to_tuple(forwarded_for)), req, state}
    end
  end

  defp to_tuple(client_ip) do
    client_ip
    |> hd
    |> String.split(".")
    |> Enum.map(fn(x) -> String.to_integer(x) end)
    |> List.to_tuple
  end

  defp response(:local) do
    [origin: ""] |> JSX.encode!
  end

  defp response(ip) do
    ip = :inet_parse.ntoa(ip) |> to_string
    [origin: ip] |> JSX.encode!
  end
end
