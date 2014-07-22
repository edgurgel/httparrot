defmodule HTTParrot.RelativeRedirectHandler do
  @moduledoc """
  Redirects to the relative foo URL.
  """
  use HTTParrot.Cowboy, methods: ~w(GET HEAD OPTIONS)

  def malformed_request(req, state) do
    HTTParrot.RedirectHandler.malformed_request(req, state)
  end

  def resource_exists(req, state), do: {false, req, state}
  def previously_existed(req, state), do: {true, req, state}

  def moved_permanently(req, n) do
    url = if n > 1, do: "/redirect/#{n-1}", else: "/get"
    {{true, url}, req, nil}
  end
end
