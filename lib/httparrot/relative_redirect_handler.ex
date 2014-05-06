defmodule HTTParrot.RelativeRedirectHandler do
  @moduledoc """
  Redirects to the relative foo URL.
  """

  def init(_transport, _req, _opts) do
    {:upgrade, :protocol, :cowboy_rest}
  end

  def allowed_methods(req, state) do
    {~W(GET HEAD OPTIONS), req, state}
  end

  def malformed_request(req, state) do
    HTTParrot.RedirectHandler.malformed_request(req, state)
  end

  def resource_exists(req, state), do: {false, req, state}
  def previously_existed(req, state), do: {true, req, state}

  def moved_permanently(req, n) do
    url = if n > 1, do: "/redirect/#{n-1}", else: "/get"
    {{true, url}, req, nil}
  end

  def terminate(_, _, _), do: :ok
end
