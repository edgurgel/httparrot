defmodule HTTParrot.GeneralRequestInfo do
  def retrieve(req) do
    {args, req} = :cowboy_req.qs_vals(req)
    {headers, req} = :cowboy_req.headers(req)
    {url, req} = :cowboy_req.url(req)
    {{ip, _port}, req} = :cowboy_req.peer(req)

    ip = :inet_parse.ntoa(ip) |> to_string
    args = flatten_dict(args)

    {[args: args, headers: headers, url: url, origin: ip], req}
  end

  @doc """
  Group by keys and if duplicated keys, aggregate them as a list

  iex> flatten_dict([a: "v1", a: "v2", b: "v3"])
  %{a: ["v1", "v2"], b: "v3"}
  """
  @spec flatten_dict(list) :: map
  def flatten_dict([]), do: %{}
  def flatten_dict(args) do
    Enum.group_by(args, %{}, fn {k, _} -> k end)
      |> Enum.traverse(fn {k1, v1} ->
           values = Enum.map(v1, fn {_, v2} -> v2 end)
             |> Enum.reverse
             |> flatten_if_list_of_one
           {k1, values}
         end)
  end

  defp flatten_if_list_of_one([h]), do: h
  defp flatten_if_list_of_one(list), do: list
end
