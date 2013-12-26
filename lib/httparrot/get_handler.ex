defmodule HTTParrot.GetHandler do
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
    {args, req} = :cowboy_req.qs_vals(req)
    {headers, req} = :cowboy_req.headers(req)
    {url, req} = :cowboy_req.url(req)
    {{ip, _port}, req} = :cowboy_req.peer(req)
    {response(args, headers, url, ip), req, state}
  end

  defp response(args, headers, url, ip) do
    ip = :inet_parse.ntoa(ip) |> to_string
    if args == [], do: args = [{}]

    [args: args, headers: headers, url: url, origin: ip]
    |> JSEX.encode!
  end

  def terminate(_, _, _), do: :ok
end
