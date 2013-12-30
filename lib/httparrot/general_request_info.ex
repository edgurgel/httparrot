defmodule HTTParrot.GeneralRequestInfo do
  def retrieve(req) do
    {args, req} = :cowboy_req.qs_vals(req)
    {headers, req} = :cowboy_req.headers(req)
    {url, req} = :cowboy_req.url(req)
    {{ip, _port}, req} = :cowboy_req.peer(req)

    ip = :inet_parse.ntoa(ip) |> to_string
    if args == [], do: args = [{}]

    {[args: args, headers: headers, url: url, origin: ip], req}
  end
end
