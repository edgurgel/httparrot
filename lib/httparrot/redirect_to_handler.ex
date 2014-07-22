defmodule HTTParrot.RedirectToHandler do
  @moduledoc """
  Redirects to the foo URL.
  """
  use HTTParrot.Cowboy, methods: ~w(GET HEAD OPTIONS)

  def malformed_request(req, state) do
    {url, req} = :cowboy_req.qs_val("url", req, nil)
    if url, do: {false, req, url}, else: {true, req, state}
  end

  def resource_exists(req, state), do: {false, req, state}
  def previously_existed(req, state), do: {true, req, state}

  def moved_permanently(req, url) do
    {{true, url}, req, url}
  end
end
