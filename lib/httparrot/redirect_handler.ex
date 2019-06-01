defmodule HTTParrot.RedirectHandler do
  @moduledoc """
  Redirects to the foo URL.
  """
  use HTTParrot.Cowboy, methods: ~w(GET HEAD OPTIONS)

  def malformed_request(req, state) do
    {n, req} = :cowboy_req.binding(:n, req)

    try do
      n = n |> String.to_integer() |> max(1)
      {false, req, n}
    rescue
      ArgumentError -> {true, req, state}
    end
  end

  def resource_exists(req, state), do: {false, req, state}
  def previously_existed(req, state), do: {true, req, state}

  def moved_permanently(req, n) do
    {host_url, req} = :cowboy_req.uri(req)
    url = if n > 1, do: "/redirect/#{n - 1}", else: "/get"
    {{true, host_url <> url}, req, nil}
  end
end
