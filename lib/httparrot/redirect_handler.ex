defmodule HTTParrot.RedirectHandler do
  @moduledoc """
  Redirects to the foo URL.
  """

  def init(_transport, _req, _opts) do
    {:upgrade, :protocol, :cowboy_rest}
  end

  def allowed_methods(req, state) do
    {~W(GET HEAD OPTIONS), req, state}
  end

  def malformed_request(req, state) do
    {n, req} = :cowboy_req.binding(:n, req)
    try do
      n = n |> String.to_integer |> max(1)
      {false, req, n}
    rescue
      ArgumentError -> {true, req, state}
    end
  end

  def resource_exists(req, state), do: {false, req, state}
  def previously_existed(req, state), do: {true, req, state}

  def moved_permanently(req, n) do
    {host_url, req} = :cowboy_req.host_url(req)
    url = if n > 1, do: "/redirect/#{n-1}", else: "/get"
    {{true, host_url <> url}, req, nil}
  end

  def terminate(_, _, _), do: :ok
end
