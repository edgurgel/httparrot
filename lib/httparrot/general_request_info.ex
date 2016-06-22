defmodule HTTParrot.GeneralRequestInfo do
  def retrieve(req) do
    {args, req} = :cowboy_req.qs_vals(req)
    {headers, req} = :cowboy_req.headers(req)
    {url, req} = :cowboy_req.url(req)
    {{ip, _port}, req} = :cowboy_req.peer(req)

    ip = :inet_parse.ntoa(ip) |> to_string
    args = group_by_keys(args)

    {[args: args, headers: headers, url: url, origin: ip], req}
  end

  @doc """
  Group by keys and if duplicated keys, aggregate them as a list

  iex> group_by_keys([a: "v1", a: "v2", b: "v3"])
  %{a: ["v1", "v2"], b: "v3"}
  """
  @spec group_by_keys(list) :: map
  def group_by_keys([]), do: %{}
  def group_by_keys(args) do
    Enum.group_by(args, &elem(&1, 0), &elem(&1, 1))
    |> Enum.map(fn {k, v} -> {k, flatten_if_list_of_one(v)} end)
    |> Map.new
  end

  defp flatten_if_list_of_one([h]), do: h
  defp flatten_if_list_of_one(list), do: list
end
