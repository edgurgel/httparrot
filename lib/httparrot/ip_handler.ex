defmodule HTTParrot.IPHandler do
  def init(_transport, _req, _opts) do
    {:upgrade, :protocol, :cowboy_rest}
  end

  def allowed_methods(req, state) do
    {["GET"], req, state}
  end

  def content_types_provided(req, state) do
    {[{{"application", "json", []}, :get_json}], req, state}
  end

  def get_json(req, state) do
    {{ip, _port}, req} = :cowboy_req.peer(req)
    {response(ip), req, state}
  end

  defp response(ip) do
    ip = :inet_parse.ntoa(ip) |> to_string

    [origin: ip]
    |> JSEX.encode!
  end

  def terminate(_, _, _), do: :ok
end
